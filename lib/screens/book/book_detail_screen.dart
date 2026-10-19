import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../models/book_listing.dart';
import '../../models/views.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/loan_provider.dart';
import '../../widgets/book_cover.dart';
import '../../widgets/common.dart';
import '../../widgets/review_card.dart';
import '../../widgets/star_rating.dart';
import '../../core/format.dart';
import 'write_review_screen.dart';

class BookDetailScreen extends StatefulWidget {
  final int bookId;
  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late Future<BookDetailData?> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final me = context.read<AuthProvider>().user!;
    _future = context.read<CatalogProvider>().loadDetail(widget.bookId, me.id!);
  }

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  Future<void> _requestLoan(ListingView view) async {
    final me = context.read<AuthProvider>().user!;
    final error = await context.read<LoanProvider>().requestLoan(me, view.listing);
    if (!mounted) return;
    if (error != null) {
      showSnack(context, error, error: true);
    } else {
      showSnack(context, 'Request sent to ${view.owner.name}.');
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AuthProvider>().user!;

    return Scaffold(
      appBar: AppBar(title: const Text('Book Details')),
      body: FutureBuilder<BookDetailData?>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data;
          if (data == null) {
            return const EmptyState(
                icon: Icons.menu_book_outlined, title: 'Book not found', message: 'It may have been removed.');
          }

          final book = data.book;
          final loanListing = data.listings
              .where((l) => l.listing.type == ListingType.loan && l.listing.status == ListingStatus.available)
              .toList();
          final saleListings = data.listings
              .where((l) => l.listing.type == ListingType.sale && l.listing.status == ListingStatus.available)
              .toList();
          final myLoanListing = loanListing.where((l) => l.listing.ownerUserId == me.id).toList();
          final borrowableListing = loanListing.where((l) => l.listing.ownerUserId != me.id).toList();

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              children: [
                Center(child: BookCover(book: book, width: 190, height: 270, radius: 18, showTitle: true)),
                const SizedBox(height: 20),
                Text(book.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.brown900)),
                const SizedBox(height: 4),
                Text('by ${book.author} · ${book.genre}',
                    textAlign: TextAlign.center, style: const TextStyle(color: AppColors.grayText, fontSize: 14)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StarRating(rating: data.averageRating, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      data.reviews.isEmpty
                          ? 'No ratings yet'
                          : '${data.averageRating.toStringAsFixed(1)} · ${data.reviews.length} review${data.reviews.length == 1 ? '' : 's'}',
                      style: const TextStyle(color: AppColors.grayText, fontSize: 13),
                    ),
                  ],
                ),
                if (book.description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(book.description,
                      style: const TextStyle(color: AppColors.brown700, height: 1.5, fontSize: 14)),
                ],
                if (data.listings.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  const Text('Available from readers',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: AppColors.brown900)),
                  const SizedBox(height: 10),
                  ...borrowableListing.map((v) => _ListingRow(
                        view: v,
                        actionLabel: 'Request',
                        onAction: () => _requestLoan(v),
                      )),
                  ...saleListings.map((v) => _ListingRow(
                        view: v,
                        actionLabel: null,
                        onAction: null,
                      )),
                  ...myLoanListing.map((v) => _ListingRow(view: v, actionLabel: null, onAction: null, isMine: true)),
                ],
                const SizedBox(height: 26),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Reviews',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 19, color: AppColors.brown900)),
                    TextButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => WriteReviewScreen(presetBook: book)),
                        );
                        await _refresh();
                      },
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      label: const Text('Write a Review'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (data.reviews.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('No reviews yet — be the first to share your thoughts.',
                        style: TextStyle(color: AppColors.grayText)),
                  )
                else
                  ...data.reviews.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: ReviewCard(item: item, showBook: false),
                      )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ListingRow extends StatelessWidget {
  final ListingView view;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isMine;

  const _ListingRow({required this.view, this.actionLabel, this.onAction, this.isMine = false});

  @override
  Widget build(BuildContext context) {
    final l = view.listing;
    final isLoan = l.type == ListingType.loan;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.tan100.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          PillLabel(
            text: isLoan ? 'Loan' : formatPrice(l.price ?? 0),
            background: isLoan ? AppColors.green : AppColors.gold,
            foreground: Colors.white,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isMine ? 'Your listing · ${l.condition.label}' : '${view.owner.name} · ${l.condition.label}',
              style: const TextStyle(fontSize: 13.5, color: AppColors.brown700, fontWeight: FontWeight.w600),
            ),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!))
          else if (!isMine)
            const Text('Contact seller', style: TextStyle(fontSize: 12, color: AppColors.grayText)),
        ],
      ),
    );
  }
}
