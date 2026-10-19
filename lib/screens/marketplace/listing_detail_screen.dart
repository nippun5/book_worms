import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/format.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/repositories/listing_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../models/book_listing.dart';
import '../../models/views.dart';
import '../../providers/auth_provider.dart';
import '../../providers/loan_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../widgets/book_cover.dart';
import '../../widgets/common.dart';

class ListingDetailScreen extends StatefulWidget {
  final int listingId;
  const ListingDetailScreen({super.key, required this.listingId});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  final _listings = ListingRepository();
  final _books = BookRepository();
  final _users = UserRepository();
  late Future<ListingView?> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = _fetch();
  }

  Future<ListingView?> _fetch() async {
    final listing = await _listings.findById(widget.listingId);
    if (listing == null) return null;
    final book = await _books.findById(listing.bookId);
    final owner = await _users.findById(listing.ownerUserId);
    if (book == null || owner == null) return null;
    return ListingView(listing: listing, book: book, owner: owner);
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

  Future<void> _toggleAvailability(ListingView view) async {
    final me = context.read<AuthProvider>().user!;
    final newStatus =
        view.listing.status == ListingStatus.available ? ListingStatus.unavailable : ListingStatus.available;
    await context.read<MarketplaceProvider>().setStatus(me, view.listing, newStatus);
    await _refresh();
  }

  Future<void> _delete(ListingView view) async {
    final ok = await confirmDialog(
      context,
      title: 'Delete this listing?',
      message: 'This removes it from the marketplace for everyone. This can\'t be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!ok) return;
    final me = context.read<AuthProvider>().user!;
    await context.read<MarketplaceProvider>().remove(me, view.listing);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AuthProvider>().user!;

    return Scaffold(
      appBar: AppBar(title: const Text('Listing')),
      body: FutureBuilder<ListingView?>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final view = snapshot.data;
          if (view == null) {
            return const EmptyState(
                icon: Icons.inventory_2_outlined, title: 'Listing not found', message: 'It may have been removed.');
          }

          final l = view.listing;
          final isOwner = l.ownerUserId == me.id;
          final isLoan = l.type == ListingType.loan;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              children: [
                Center(child: BookCover(book: view.book, width: 190, height: 270, radius: 18, showTitle: true)),
                const SizedBox(height: 20),
                Text(view.book.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.brown900)),
                const SizedBox(height: 4),
                Text('by ${view.book.author}',
                    textAlign: TextAlign.center, style: const TextStyle(color: AppColors.grayText, fontSize: 14)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PillLabel(
                      text: isLoan ? 'For Loan' : formatPrice(l.price ?? 0),
                      background: isLoan ? AppColors.green : AppColors.gold,
                      foreground: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    PillLabel(text: l.condition.label),
                    const SizedBox(width: 10),
                    PillLabel(
                      text: l.status == ListingStatus.available ? 'Available' : 'Unavailable',
                      background: l.status == ListingStatus.available ? AppColors.tan100 : AppColors.brown300,
                      foreground: l.status == ListingStatus.available ? AppColors.brown700 : Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Color(view.owner.avatarColorValue),
                        child: Text(view.owner.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(isOwner ? 'You' : view.owner.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text(isOwner ? 'Your listing' : view.owner.email,
                                style: const TextStyle(fontSize: 12.5, color: AppColors.grayText)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (l.note.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  const Text('Note from the owner', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.brown900)),
                  const SizedBox(height: 6),
                  Text(l.note, style: const TextStyle(color: AppColors.brown700, height: 1.5)),
                ],
                const SizedBox(height: 28),
                if (isOwner) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _toggleAvailability(view),
                      icon: Icon(l.status == ListingStatus.available ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                      label: Text(l.status == ListingStatus.available ? 'Mark unavailable' : 'Mark available'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => _delete(view),
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.red),
                      label: const Text('Delete listing', style: TextStyle(color: AppColors.red)),
                    ),
                  ),
                ] else if (isLoan) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: l.status == ListingStatus.available ? () => _requestLoan(view) : null,
                      child: Text(l.status == ListingStatus.available ? 'Request to Borrow' : 'Currently unavailable'),
                    ),
                  ),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.tan100.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(14)),
                    child: const Text(
                      'This book is listed for sale. Reach out to the owner directly using the contact info above to arrange purchase.',
                      style: TextStyle(fontSize: 13, color: AppColors.brown700, height: 1.4),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
