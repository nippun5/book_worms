import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/common.dart';
import '../../widgets/star_rating.dart';

class ManageReviewsScreen extends StatelessWidget {
  const ManageReviewsScreen({super.key});

  Future<void> _delete(BuildContext context, int reviewId) async {
    final ok = await confirmDialog(
      context,
      title: 'Remove this review?',
      message: 'This can\'t be undone.',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (!ok) return;
    await context.read<AdminProvider>().deleteReview(reviewId);
    if (context.mounted) showSnack(context, 'Review removed.');
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Reviews')),
      body: admin.reviews.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: admin.reviews.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final item = admin.reviews[i];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text('${item.author.name} on "${item.book.title}"',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.red, size: 20),
                            onPressed: () => _delete(context, item.review.id!),
                          ),
                        ],
                      ),
                      StarRating(rating: item.review.rating.toDouble(), size: 15),
                      const SizedBox(height: 6),
                      Text(item.review.text, style: const TextStyle(fontSize: 13, color: AppColors.brown700, height: 1.4)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
