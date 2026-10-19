import 'package:flutter/foundation.dart';
import '../data/repositories/book_repository.dart';
import '../data/repositories/listing_repository.dart';
import '../data/repositories/loan_repository.dart';
import '../data/repositories/review_repository.dart';
import '../data/repositories/user_repository.dart';
import '../models/book.dart';
import '../models/user.dart';
import '../models/views.dart';

class AdminStats {
  final int users;
  final int books;
  final int reviews;
  final int listings;
  final int activeLoans;

  const AdminStats({
    required this.users,
    required this.books,
    required this.reviews,
    required this.listings,
    required this.activeLoans,
  });
}

class AdminProvider extends ChangeNotifier {
  final _users = UserRepository();
  final _books = BookRepository();
  final _reviews = ReviewRepository();
  final _listings = ListingRepository();
  final _loans = LoanRepository();

  AdminStats? stats;
  List<AppUser> users = [];
  List<Book> books = [];
  List<ListingView> listings = [];
  List<FeedItem> reviews = [];
  bool loading = false;

  Future<void> load() async {
    loading = true;
    notifyListeners();

    users = await _users.getAllUsers();
    books = await _books.getAllBooks();
    final userMap = {for (final u in users) u.id!: u};
    final bookMap = {for (final b in books) b.id!: b};

    listings = [];
    for (final l in await _listings.getAll()) {
      final b = bookMap[l.bookId];
      final o = userMap[l.ownerUserId];
      if (b != null && o != null) listings.add(ListingView(listing: l, book: b, owner: o));
    }

    reviews = [];
    for (final r in await _reviews.getAllReviews()) {
      final b = bookMap[r.bookId];
      final a = userMap[r.userId];
      if (b != null && a != null) reviews.add(FeedItem(review: r, book: b, author: a));
    }

    stats = AdminStats(
      users: users.length,
      books: books.length,
      reviews: reviews.length,
      listings: listings.length,
      activeLoans: await _loans.countActive(),
    );
    loading = false;
    notifyListeners();
  }

  /// Admins cannot suspend themselves or other admins.
  bool canBan(AppUser admin, AppUser target) => target.id != admin.id && target.role != UserRole.admin;

  Future<void> setBanned(AppUser target, bool banned) async {
    await _users.setBanned(target.id!, banned);
    await load();
  }

  Future<void> setRole(AppUser target, UserRole role) async {
    await _users.setRole(target.id!, role);
    await load();
  }

  Future<void> deleteReview(int reviewId) async {
    await _reviews.deleteReview(reviewId);
    await load();
  }

  Future<void> deleteListing(int listingId) async {
    await _listings.deleteListing(listingId);
    await load();
  }

  Future<void> deleteBook(int bookId) async {
    await _books.deleteBookCascade(bookId);
    await load();
  }
}
