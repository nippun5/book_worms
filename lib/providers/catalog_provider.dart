import 'package:flutter/foundation.dart';
import '../core/app_colors.dart';
import '../data/repositories/book_repository.dart';
import '../data/repositories/listing_repository.dart';
import '../data/repositories/review_repository.dart';
import '../data/repositories/user_repository.dart';
import '../models/book.dart';
import '../models/book_listing.dart';
import '../models/views.dart';

/// Owns the shared book catalog and builds the Book Details view.
class CatalogProvider extends ChangeNotifier {
  final _books = BookRepository();
  final _reviews = ReviewRepository();
  final _users = UserRepository();
  final _listings = ListingRepository();

  List<Book> _all = [];
  List<Book> get books => _all;

  Future<void> load() async {
    _all = await _books.getAllBooks();
    notifyListeners();
  }

  /// Reuses an existing book with the same title + author, otherwise creates one.
  Future<Book> findOrCreate({
    required String title,
    required String author,
    String genre = 'General',
    required int userId,
  }) async {
    final t = title.trim();
    final a = author.trim();
    await load();
    for (final b in _all) {
      if (b.title.toLowerCase() == t.toLowerCase() && b.author.toLowerCase() == a.toLowerCase()) {
        return b;
      }
    }
    final created = await _books.addBook(Book(
      title: t,
      author: a,
      genre: genre.trim().isEmpty ? 'General' : genre.trim(),
      coverColorValue: AppColors.accentFor(t.hashCode).value,
      addedByUserId: userId,
    ));
    await load();
    return created;
  }

  Future<List<Book>> search(String query) => _books.search(query.trim());

  Future<BookDetailData?> loadDetail(int bookId, int myUserId) async {
    final book = await _books.findById(bookId);
    if (book == null) return null;

    final users = {for (final u in await _users.getAllUsers()) u.id!: u};
    final reviews = await _reviews.getReviewsForBook(bookId);
    final liked = await _reviews.getLikedReviewIds(myUserId);
    final listings = await _listings.getByBook(bookId);

    final reviewItems = <FeedItem>[];
    for (final r in reviews) {
      final author = users[r.userId];
      if (author == null || author.isBanned) continue;
      reviewItems.add(FeedItem(review: r, book: book, author: author, likedByMe: liked.contains(r.id)));
    }

    final avg = reviewItems.isEmpty
        ? 0.0
        : reviewItems.map((e) => e.review.rating).reduce((a, b) => a + b) / reviewItems.length;

    final listingViews = <ListingView>[];
    for (final l in listings) {
      final owner = users[l.ownerUserId];
      if (owner == null || owner.isBanned) continue;
      listingViews.add(ListingView(listing: l, book: book, owner: owner));
    }

    return BookDetailData(book: book, reviews: reviewItems, averageRating: avg, listings: listingViews);
  }
}
