import 'book.dart';
import 'book_listing.dart';
import 'loan_transaction.dart';
import 'review.dart';
import 'user.dart';

/// A review together with the book and author it refers to (feed card).
class FeedItem {
  final Review review;
  final Book book;
  final AppUser author;
  final BookListing? openListing; // an available listing for this book, if any
  final bool likedByMe;

  const FeedItem({
    required this.review,
    required this.book,
    required this.author,
    this.openListing,
    this.likedByMe = false,
  });
}

/// A marketplace listing with its book and owner resolved.
class ListingView {
  final BookListing listing;
  final Book book;
  final AppUser owner;

  const ListingView({required this.listing, required this.book, required this.owner});
}

/// A loan with both parties and the book resolved.
class LoanView {
  final LoanTransaction loan;
  final Book book;
  final AppUser owner; // lender
  final AppUser borrower;

  const LoanView({required this.loan, required this.book, required this.owner, required this.borrower});
}

/// Everything the Book Details screen needs.
class BookDetailData {
  final Book book;
  final List<FeedItem> reviews;
  final double averageRating;
  final List<ListingView> listings;

  const BookDetailData({
    required this.book,
    required this.reviews,
    required this.averageRating,
    required this.listings,
  });
}
