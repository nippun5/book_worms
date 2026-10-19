# Book Worms 📚

A Flutter app for readers: rate and review books, browse a Facebook-Marketplace-style
feed of trending reviews, and sell or loan out books you own — complete with a
borrowed/lent tracker and an admin panel.

## Features

- **Auth** — email/password sign up & login (SHA-256 hashed, stored locally), session
  persisted between launches.
- **Review feed (Dashboard)** — Trending / Latest / Mine tabs, like button, in-app search.
- **Book details** — average rating, all reviews, and any active marketplace listings
  for that book.
- **Marketplace** — list a book to sell (set a price) or loan (free), browse/filter by
  type, manage your own listings.
- **My Loans** — Borrowed and Lent tabs with the full lifecycle: request → approve/decline
  → active (with due date) → returned. Approving one request automatically declines
  competing requests for the same book.
- **Admin panel** — user management (suspend/unsuspend, promote/demote), and moderation
  for books, listings and reviews. Cascading delete keeps the database consistent.
- **Brown & white Material 3 theme**, bundled Poppins type, custom launcher icon.

## Getting started

This code was written and reviewed in an environment without the Flutter SDK installed,
so it hasn't been run through `flutter analyze` / `flutter run` — read it over and let
me know if anything needs a fix. To run it locally:

```bash
# 1. Unzip, then from the project root, generate the native platform folders
#    (android/, ios/, etc.) — flutter create will NOT overwrite the existing
#    lib/ or pubspec.yaml, it only fills in what's missing:
flutter create .

# 2. Get packages
flutter pub get

# 3. Generate the native launcher icon from assets/icon/icon.png
dart run flutter_launcher_icons

# 4. Run it
flutter run
```

Requires Flutter 3.27+ / Dart 3.6+ (for the newer `Color.toARGB32()` /
`withValues()` APIs used in the theme).

## Demo accounts

The app seeds itself with demo data on first launch (see `lib/data/seed_service.dart`):

| Role   | Email                | Password   |
|--------|-----------------------|------------|
| Admin  | admin@bookworms.app   | admin1234  |
| Reader | demo@bookworms.app    | demo1234   |

Six other demo readers (Maya, Daniel, Priya, James, Sarah, Noah) are also seeded with
password `password1`, so you can log in as different people to test the loan-approval
and review flows both ways.

## Architecture

```
lib/
  core/            # theme, colors, formatting helpers
  models/          # plain data classes + views.dart (joined view-models for the UI)
  data/
    db_helper.dart       # SQLite schema (6 tables incl. a review_likes join table)
    repositories/        # one repository per table — all DB access lives here
    seed_service.dart    # first-run demo data
  providers/       # ChangeNotifier state: Auth, Catalog, Feed, Marketplace, Loan, Admin
  widgets/         # shared UI: ReviewCard, ListingCard, LoanCard, BookCover, etc.
  screens/         # one folder per feature area
```

The **users and books databases** requested in the brief are implemented as a local
SQLite database (`book_worms.db`) with 6 tables: `users`, `books`, `reviews`,
`review_likes`, `listings`, `loans`. This makes the app fully functional standalone,
with no server required.

## Connecting the Java backend (optional)

A matching Spring Boot backend skeleton is included separately (`/backend`) with the
same entities and a REST API (`/api/users`, `/api/books`, `/api/reviews`,
`/api/listings`, `/api/loans`). To move from local-only to server-backed:

1. Stand up the backend (see its own README) against MySQL/Postgres.
2. Replace the SQLite calls in `lib/data/repositories/*.dart` with `http` calls to the
   backend's REST endpoints (the method signatures are already shaped so this is a
   drop-in swap — nothing above the repository layer needs to change).

## Known scope boundaries (by design, for this first version)

- **Buying a "for sale" listing** shows the owner's contact info rather than a full
  checkout/payment flow — there's no payment processor wired up.
- No push notifications — the "Lent" tab badge shows pending requests when you open
  the app instead.
- No photo upload for book covers; covers are generated placeholder colors. Wiring up
  `image_picker` for real cover photos would be a natural next step.

## Store listing assets

Generated to match this app's branding — see the `/store-assets` folder you received
alongside this project: a 512×512 icon, 1024×500 feature graphic, and 3 screenshots.
