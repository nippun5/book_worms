import 'package:flutter/foundation.dart';
import '../data/repositories/book_repository.dart';
import '../data/repositories/listing_repository.dart';
import '../data/repositories/loan_repository.dart';
import '../data/repositories/user_repository.dart';
import '../models/book_listing.dart';
import '../models/loan_transaction.dart';
import '../models/user.dart';
import '../models/views.dart';

class LoanProvider extends ChangeNotifier {
  static const loanPeriodDays = 14;

  final _loans = LoanRepository();
  final _listings = ListingRepository();
  final _books = BookRepository();
  final _users = UserRepository();

  List<LoanView> _borrowed = [];
  List<LoanView> _lent = [];
  bool _loading = false;

  /// Books I have taken on loan (or requested).
  List<LoanView> get borrowed => _borrowed;

  /// Books I have given out on loan (or that others requested from me).
  List<LoanView> get lent => _lent;
  bool get loading => _loading;

  /// Requests from other readers waiting for my decision.
  int get pendingRequestsForMe => _lent.where((v) => v.loan.status == LoanStatus.requested).length;

  Future<void> load(AppUser me) async {
    _loading = true;
    notifyListeners();

    final books = {for (final b in await _books.getAllBooks()) b.id!: b};
    final users = {for (final u in await _users.getAllUsers()) u.id!: u};

    List<LoanView> resolve(List<LoanTransaction> raw) {
      final out = <LoanView>[];
      for (final l in raw) {
        final book = books[l.bookId];
        final owner = users[l.ownerUserId];
        final borrower = users[l.borrowerUserId];
        if (book == null || owner == null || borrower == null) continue;
        out.add(LoanView(loan: l, book: book, owner: owner, borrower: borrower));
      }
      return out;
    }

    _borrowed = resolve(await _loans.getBorrowedBy(me.id!));
    _lent = resolve(await _loans.getLentBy(me.id!));
    _loading = false;
    notifyListeners();
  }

  /// Returns an error message, or null on success.
  Future<String?> requestLoan(AppUser me, BookListing listing) async {
    if (listing.type != ListingType.loan) return 'This book is listed for sale, not for loan.';
    if (listing.ownerUserId == me.id) return "You can't borrow your own book.";
    final fresh = await _listings.findById(listing.id!);
    if (fresh == null || fresh.status != ListingStatus.available) {
      return 'Sorry, this book is no longer available.';
    }
    if (await _loans.hasOpenRequest(listing.id!, me.id!)) {
      return 'You already have an open request for this book.';
    }
    await _loans.requestLoan(LoanTransaction(
      listingId: listing.id!,
      bookId: listing.bookId,
      ownerUserId: listing.ownerUserId,
      borrowerUserId: me.id!,
    ));
    await load(me);
    return null;
  }

  /// Owner accepts a request: the loan becomes active and the book is
  /// unavailable to others until it is returned.
  Future<String?> approve(AppUser me, LoanView view) async {
    final listing = await _listings.findById(view.loan.listingId);
    if (listing == null || listing.status != ListingStatus.available) {
      return 'This book is already on loan to someone else.';
    }
    await _loans.updateStatus(
      view.loan.id!,
      LoanStatus.active,
      dueDate: DateTime.now().add(const Duration(days: loanPeriodDays)),
    );
    await _loans.declineOtherRequests(listing.id!, view.loan.id!);
    await _listings.updateStatus(listing.id!, ListingStatus.unavailable);
    await load(me);
    return null;
  }

  Future<void> decline(AppUser me, LoanView view) async {
    await _loans.updateStatus(view.loan.id!, LoanStatus.declined);
    await load(me);
  }

  /// Owner confirms the book is back; it becomes available again.
  Future<void> markReturned(AppUser me, LoanView view) async {
    await _loans.updateStatus(view.loan.id!, LoanStatus.returned, returnedAt: DateTime.now());
    await _listings.updateStatus(view.loan.listingId, ListingStatus.available);
    await load(me);
  }
}
