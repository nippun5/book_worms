import 'package:flutter/foundation.dart';
import '../data/repositories/book_repository.dart';
import '../data/repositories/listing_repository.dart';
import '../data/repositories/review_repository.dart';
import '../data/repositories/user_repository.dart';
import '../models/book_listing.dart';
import '../models/review.dart';
import '../models/user.dart';
import '../models/views.dart';

enum FeedTab { trending, latest, mine }

class FeedProvider extends ChangeNotifier {
  final _reviews = ReviewRepository();
  final _books = BookRepository();
  final _users = UserRepository();
  final _listings = ListingRepository();

  FeedTab _tab = FeedTab.trending;
  List<FeedItem> _items = [];
  bool _loading = false;

  FeedTab get tab => _tab;
  List<FeedItem> get items => _items;
  bool get loading => _loading;

  Future<void> load(AppUser me, {bool silent = false}) async {
    if (!silent) {
      _loading = true;
      notifyListeners();
    }

    List<Review> reviews;
    if (_tab == FeedTab.trending) {
      reviews = await _reviews.getTrendingReviews();
    } else if (_tab == FeedTab.latest) {
      reviews = await _reviews.getRecentReviews();
    } else {
      reviews = await _reviews.getReviewsByUser(me.id!);
    }

    final books = {for (final b in await _books.getAllBooks()) b.id!: b};
    final users = {for (final u in await _users.getAllUsers()) u.id!: u};
    final listings = await _listings.getAll();
    final liked = await _reviews.getLikedReviewIds(me.id!);

    final items = <FeedItem>[];
    for (final r in reviews) {
      final book = books[r.bookId];
      final author = users[r.userId];
      if (book == null || author == null || author.isBanned) continue;

      BookListing? open;
      for (final l in listings) {
        if (l.bookId == r.bookId && l.status == ListingStatus.available && l.ownerUserId != me.id) {
          open = l;
          break;
        }
      }
      items.add(FeedItem(
        review: r,
        book: book,
        author: author,
        openListing: open,
        likedByMe: liked.contains(r.id),
      ));
    }

    _items = items;
    _loading = false;
    notifyListeners();
  }

  Future<void> setTab(FeedTab tab, AppUser me) async {
    if (_tab == tab) return;
    _tab = tab;
    await load(me);
  }

  Future<void> toggleLike(FeedItem item, AppUser me) async {
    await _reviews.toggleLike(item.review.id!, me.id!);
    await load(me, silent: true);
  }

  Future<void> addReview({
    required AppUser me,
    required int bookId,
    required int rating,
    required String text,
  }) async {
    await _reviews.addReview(Review(bookId: bookId, userId: me.id!, rating: rating, text: text.trim()));
    await load(me, silent: true);
  }
}
