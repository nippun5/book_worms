import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/format.dart';
import '../../models/book_listing.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/common.dart';

class ManageListingsScreen extends StatelessWidget {
  const ManageListingsScreen({super.key});

  Future<void> _delete(BuildContext context, int listingId, String title) async {
    final ok = await confirmDialog(
      context,
      title: 'Remove listing for "$title"?',
      message: 'This can\'t be undone.',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (!ok) return;
    await context.read<AdminProvider>().deleteListing(listingId);
    if (context.mounted) showSnack(context, 'Listing removed.');
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Listings')),
      body: admin.listings.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: admin.listings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final v = admin.listings[i];
                final isLoan = v.listing.type == ListingType.loan;
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 56,
                        decoration: BoxDecoration(color: Color(v.book.coverColorValue), borderRadius: BorderRadius.circular(6)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(v.book.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text('${v.owner.name} · ${isLoan ? "Loan" : formatPrice(v.listing.price ?? 0)}',
                                style: const TextStyle(fontSize: 12.5, color: AppColors.grayText)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.red),
                        onPressed: () => _delete(context, v.listing.id!, v.book.title),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
