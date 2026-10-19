import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/format.dart';
import '../models/book_listing.dart';
import '../models/views.dart';
import 'book_cover.dart';
import 'common.dart';
import 'star_rating.dart';
import 'user_avatar.dart';

/// Feed card: who reviewed, which book, stars, text, and a like button.
class ReviewCard extends StatelessWidget {
  final FeedItem item;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final bool showBook;

  const ReviewCard({super.key, required this.item, this.onTap, this.onLike, this.showBook = true});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final listing = item.openListing;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  UserAvatar(user: item.author, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.author.name, style: textTheme.titleMedium?.copyWith(fontSize: 14)),
                        Text(showBook ? 'reviewed a book' : 'wrote a review', style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Text(timeAgo(item.review.createdAt), style: textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 14),
              if (showBook)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BookCover(book: item.book, width: 56, height: 78, radius: 8),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.book.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleMedium?.copyWith(fontSize: 16)),
                          Text('by ${item.book.author}', style: textTheme.bodySmall),
                          const SizedBox(height: 6),
                          StarRating(rating: item.review.rating.toDouble(), size: 18),
                          if (listing != null) ...[
                            const SizedBox(height: 8),
                            PillLabel(
                              text: listing.type == ListingType.loan
                                  ? 'For Loan'
                                  : 'For Sale · ${formatPrice(listing.price ?? 0)}',
                              background: listing.type == ListingType.loan ? AppColors.green : AppColors.brown300,
                              foreground: Colors.white,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                )
              else
                StarRating(rating: item.review.rating.toDouble(), size: 18),
              const SizedBox(height: 12),
              Text(item.review.text, style: textTheme.bodyMedium?.copyWith(height: 1.45)),
              const SizedBox(height: 8),
              Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: onLike,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: Row(
                        children: [
                          Icon(
                            item.likedByMe ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 20,
                            color: item.likedByMe ? AppColors.red : AppColors.grayText,
                          ),
                          const SizedBox(width: 6),
                          Text('${item.review.likeCount}', style: textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
