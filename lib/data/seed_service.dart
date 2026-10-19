import '../models/user.dart';
import '../models/book.dart';
import '../models/review.dart';
import '../models/book_listing.dart';
import '../models/loan_transaction.dart';
import 'repositories/user_repository.dart';
import 'repositories/book_repository.dart';
import 'repositories/review_repository.dart';
import 'repositories/listing_repository.dart';
import 'repositories/loan_repository.dart';

/// Populates the local database with demo users, books, reviews, listings
/// and loans the first time the app runs, so the dashboard/marketplace/loans
/// screens have something meaningful to show out of the box.
///
/// Demo login: demo@bookworms.app / demo1234
/// Demo admin login: admin@bookworms.app / admin1234
class SeedService {
  final _users = UserRepository();
  final _books = BookRepository();
  final _reviews = ReviewRepository();
  final _listings = ListingRepository();
  final _loans = LoanRepository();

  static const accentColors = <int>[
    0xFFB5654A, // terracotta
    0xFF7C9473, // sage
    0xFF6E8AA3, // dusty blue
    0xFFC9A227, // mustard
    0xFF8B5E7A, // plum
    0xFF5D7A8C, // slate
  ];

  Future<void> seedIfNeeded() async {
    final existingUsers = await _users.getAllUsers();
    if (existingUsers.isNotEmpty) return; // already seeded

    final admin = (await _users.register(
      name: 'Admin',
      email: 'admin@bookworms.app',
      password: 'admin1234',
      avatarColorValue: 0xFF6B4A32,
    ))!;
    await _users.setRole(admin.id!, UserRole.admin);

    final demo = (await _users.register(
      name: 'You',
      email: 'demo@bookworms.app',
      password: 'demo1234',
      avatarColorValue: accentColors[2],
    ))!;

    final maya = (await _users.register(
      name: 'Maya R.', email: 'maya@example.com', password: 'password1', avatarColorValue: accentColors[0],
    ))!;
    final daniel = (await _users.register(
      name: 'Daniel K.', email: 'daniel@example.com', password: 'password1', avatarColorValue: accentColors[1],
    ))!;
    final priya = (await _users.register(
      name: 'Priya S.', email: 'priya@example.com', password: 'password1', avatarColorValue: accentColors[2],
    ))!;
    final james = (await _users.register(
      name: 'James T.', email: 'james@example.com', password: 'password1', avatarColorValue: accentColors[4],
    ))!;
    final sarah = (await _users.register(
      name: 'Sarah K.', email: 'sarah@example.com', password: 'password1', avatarColorValue: accentColors[3],
    ))!;
    final noah = (await _users.register(
      name: 'Noah D.', email: 'noah@example.com', password: 'password1', avatarColorValue: accentColors[5],
    ))!;

    final silentOrchard = await _books.addBook(Book(
      title: 'The Silent Orchard', author: 'L. Bennett', genre: 'Literary Fiction',
      description: 'A quiet, aching story of a family orchard and the secrets buried beneath it.',
      coverColorValue: accentColors[0], addedByUserId: sarah.id!,
    ));
    final emberAsh = await _books.addBook(Book(
      title: 'Ember & Ash', author: 'T. Osei', genre: 'Fantasy',
      description: 'A sweeping fantasy of rival kingdoms and the fire that binds them.',
      coverColorValue: accentColors[1], addedByUserId: daniel.id!,
    ));
    final notesKitchen = await _books.addBook(Book(
      title: 'Notes From a Small Kitchen', author: 'R. Alvarez', genre: 'Memoir',
      description: 'Part memoir, part cookbook — recipes and reflections from a life well-fed.',
      coverColorValue: accentColors[2], addedByUserId: priya.id!,
    ));
    final cartographer = await _books.addBook(Book(
      title: "The Cartographer's Wife", author: 'N. Duval', genre: 'Historical Fiction',
      description: 'A mapmaker\'s wife charts a life of her own in colonial-era port town.',
      coverColorValue: accentColors[3], addedByUserId: demo.id!,
    ));
    final midnightLagos = await _books.addBook(Book(
      title: 'Midnight in Lagos', author: 'O. Bello', genre: 'Thriller',
      description: 'A journalist chases a story through the sleepless streets of Lagos.',
      coverColorValue: accentColors[4], addedByUserId: noah.id!,
    ));
    final saltSilence = await _books.addBook(Book(
      title: 'Salt & Silence', author: 'K. Yamada', genre: 'Literary Fiction',
      description: 'Two sisters, a fishing village, and the words they never said.',
      coverColorValue: accentColors[5], addedByUserId: james.id!,
    ));
    final longFerry = await _books.addBook(Book(
      title: 'The Long Ferry', author: 'A. Novak', genre: 'Contemporary',
      description: 'Strangers on an overnight ferry crossing, and the stories they trade.',
      coverColorValue: accentColors[0], addedByUserId: demo.id!,
    ));

    await _reviews.addReview(Review(
      bookId: silentOrchard.id!, userId: maya.id!, rating: 5,
      text: 'A quiet, aching story that snuck up on me. Could not put it down over the weekend.',
      likeCount: 42,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ));
    await _reviews.addReview(Review(
      bookId: emberAsh.id!, userId: daniel.id!, rating: 4,
      text: 'Strong worldbuilding, pacing dips mid-book but the ending pays it all off.',
      likeCount: 19,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ));
    await _reviews.addReview(Review(
      bookId: notesKitchen.id!, userId: priya.id!, rating: 5,
      text: 'Equal parts memoir and cookbook. Recommending this to every reader I know.',
      likeCount: 63,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ));
    await _reviews.addReview(Review(
      bookId: silentOrchard.id!, userId: james.id!, rating: 4,
      text: 'Beautifully written, slow start but worth it.',
      likeCount: 10,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ));
    await _reviews.addReview(Review(
      bookId: midnightLagos.id!, userId: demo.id!, rating: 5,
      text: "Vivid sense of place — couldn't stop turning pages on this one.",
      likeCount: 5,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ));

    await _listings.addListing(BookListing(
      bookId: silentOrchard.id!, ownerUserId: sarah.id!, type: ListingType.loan,
      condition: ListingCondition.likeNew, status: ListingStatus.available,
    ));
    await _listings.addListing(BookListing(
      bookId: emberAsh.id!, ownerUserId: daniel.id!, type: ListingType.sale,
      price: 8, condition: ListingCondition.likeNew, status: ListingStatus.available,
    ));
    final lNotes = await _listings.addListing(BookListing(
      bookId: notesKitchen.id!, ownerUserId: priya.id!, type: ListingType.loan,
      condition: ListingCondition.good, status: ListingStatus.available,
    ));
    await _listings.addListing(BookListing(
      bookId: cartographer.id!, ownerUserId: demo.id!, type: ListingType.sale,
      price: 12, condition: ListingCondition.likeNew, status: ListingStatus.available,
    ));
    final lMidnight = await _listings.addListing(BookListing(
      bookId: midnightLagos.id!, ownerUserId: noah.id!, type: ListingType.loan,
      condition: ListingCondition.fair, status: ListingStatus.unavailable,
    ));
    await _listings.addListing(BookListing(
      bookId: saltSilence.id!, ownerUserId: james.id!, type: ListingType.sale,
      price: 6, condition: ListingCondition.good, status: ListingStatus.available,
    ));
    final lFerry = await _listings.addListing(BookListing(
      bookId: longFerry.id!, ownerUserId: demo.id!, type: ListingType.loan,
      condition: ListingCondition.likeNew, status: ListingStatus.unavailable,
    ));

    final now = DateTime.now();
    await _loans.requestLoan(LoanTransaction(
      listingId: lMidnight.id!, bookId: midnightLagos.id!, ownerUserId: noah.id!, borrowerUserId: demo.id!,
      status: LoanStatus.active, requestedAt: now.subtract(const Duration(days: 5)),
      dueDate: now.add(const Duration(days: 9)),
    ));
    await _loans.requestLoan(LoanTransaction(
      listingId: lFerry.id!, bookId: longFerry.id!, ownerUserId: demo.id!, borrowerUserId: maya.id!,
      status: LoanStatus.active, requestedAt: now.subtract(const Duration(days: 3)),
      dueDate: now.add(const Duration(days: 11)),
    ));
    await _loans.requestLoan(LoanTransaction(
      listingId: lNotes.id!, bookId: notesKitchen.id!, ownerUserId: priya.id!, borrowerUserId: demo.id!,
      status: LoanStatus.requested, requestedAt: now.subtract(const Duration(hours: 6)),
    ));
  }
}
