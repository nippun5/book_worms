import 'package:flutter/material.dart';
import '../core/app_colors.dart';

/// Read-only star display; supports half stars.
class StarRating extends StatelessWidget {
  final double rating;
  final double size;

  const StarRating({super.key, required this.rating, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final remaining = rating - i;
        final icon = remaining >= 0.75
            ? Icons.star_rounded
            : remaining >= 0.25
                ? Icons.star_half_rounded
                : Icons.star_outline_rounded;
        return Icon(icon, size: size, color: AppColors.gold);
      }),
    );
  }
}

/// Tappable 1-5 star picker used when writing a review.
class StarRatingInput extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final double size;

  const StarRatingInput({super.key, required this.value, required this.onChanged, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < value;
        return IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: size + 4, minHeight: size + 4),
          tooltip: '${i + 1} star${i == 0 ? '' : 's'}',
          onPressed: () => onChanged(i + 1),
          icon: Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: AppColors.gold,
          ),
        );
      }),
    );
  }
}
