import 'package:flutter/material.dart';
import '../models/book.dart';

/// Stylised placeholder cover: a solid colour block with the title on it.
class BookCover extends StatelessWidget {
  final Book book;
  final double? width;
  final double? height;
  final double radius;
  final bool showTitle;

  const BookCover({
    super.key,
    required this.book,
    this.width,
    this.height,
    this.radius = 12,
    this.showTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final base = Color(book.coverColorValue);
    return Container(
      width: width,
      height: height,
      padding: showTitle ? const EdgeInsets.all(14) : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [base, Color.lerp(base, Colors.black, 0.22)!],
        ),
      ),
      alignment: Alignment.topLeft,
      child: showTitle
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18, height: 1.25),
                ),
                const Spacer(),
                Text(book.author, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            )
          : const Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.menu_book_rounded, color: Colors.white38, size: 22),
              ),
            ),
    );
  }
}
