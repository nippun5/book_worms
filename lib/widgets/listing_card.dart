import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/format.dart';
import '../models/book_listing.dart';
import '../models/views.dart';
import 'book_cover.dart';

/// Marketplace grid tile (Facebook-Marketplace style).
class ListingCard extends StatelessWidget {
  final ListingView view;
  final VoidCallback onTap;

  const ListingCard({super.key, required this.view, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = view.listing;
    final isLoan = l.type == ListingType.loan;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  BookCover(book: view.book, radius: 0, showTitle: true),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: isLoan ? AppColors.green : AppColors.gold,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        isLoan ? 'Free Loan' : formatPrice(l.price ?? 0),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(view.book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(view.book.author, maxLines: 1, overflow: TextOverflow.ellipsis, style: textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text('Condition: ${l.condition.label}',
                      style: textTheme.bodySmall?.copyWith(color: AppColors.brown300, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
