import 'package:flutter/foundation.dart';
import '../data/repositories/book_repository.dart';
import '../data/repositories/listing_repository.dart';
import '../data/repositories/user_repository.dart';
import '../models/book.dart';
import '../models/book_listing.dart';
import '../models/user.dart';
import '../models/views.dart';

enum MarketFilter { all, sale, loan }

class MarketplaceProvider extends ChangeNotifier {
  final _listings = ListingRepository();
  final _books = BookRepository();
  final _users = UserRepository();

  MarketFilter _filter = MarketFilter.all;
  List<ListingView> _all = [];
  List<ListingView> _mine = [];
  bool _loading = false;

  MarketFilter get filter => _filter;
  bool get loading => _loading;

  /// Available listings, filtered by the selected tab.
  List<ListingView> get visible {
    return _all.where((v) {
      if (v.listing.status != ListingStatus.available) return false;
      switch (_filter) {
        case MarketFilter.all:
          return true;
        case MarketFilter.sale:
          return v.listing.type == ListingType.sale;
        case MarketFilter.loan:
          return v.listing.type == ListingType.loan;
      }
    }).toList();
  }

  /// The signed-in user's own listings (any status).
  List<ListingView> get mine => _mine;

  void setFilter(MarketFilter f) {
    _filter = f;
    notifyListeners();
  }

  Future<void> load(AppUser me) async {
    _loading = true;
    notifyListeners();

    final books = {for (final b in await _books.getAllBooks()) b.id!: b};
    final users = {for (final u in await _users.getAllUsers()) u.id!: u};
    final listings = await _listings.getAll();

    final all = <ListingView>[];
    for (final l in listings) {
      final book = books[l.bookId];
      final owner = users[l.ownerUserId];
      if (book == null || owner == null) continue;
      all.add(ListingView(listing: l, book: book, owner: owner));
    }

    _mine = all.where((v) => v.listing.ownerUserId == me.id).toList();
    _all = all.where((v) => !v.owner.isBanned).toList();
    _loading = false;
    notifyListeners();
  }

  /// Returns an error message, or null on success.
  Future<String?> postListing({
    required AppUser me,
    required Book book,
    required ListingType type,
    double? price,
    required ListingCondition condition,
    String note = '',
  }) async {
    if (type == ListingType.sale && (price == null || price <= 0)) {
      return 'Enter a price greater than 0 for a book you want to sell.';
    }
    await _listings.addListing(BookListing(
      bookId: book.id!,
      ownerUserId: me.id!,
      type: type,
      price: type == ListingType.sale ? price : null,
      condition: condition,
      note: note.trim(),
    ));
    await load(me);
    return null;
  }

  Future<void> setStatus(AppUser me, BookListing listing, ListingStatus status) async {
    await _listings.updateStatus(listing.id!, status);
    await load(me);
  }

  Future<void> remove(AppUser me, BookListing listing) async {
    await _listings.deleteListing(listing.id!);
    await load(me);
  }
}
