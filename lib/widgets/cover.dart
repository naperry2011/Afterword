import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/shapes.dart';
import '../theme/text.dart';
import '../theme/tokens.dart';

/// Cover image with a designed typographic fallback. The fallback will be used
/// more often than expected and cannot look broken.
class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    required this.bookId,
    required this.title,
    required this.author,
    this.coverUrl,
    this.width = 96,
  });

  final String bookId;
  final String title;
  final String author;
  final String? coverUrl;
  final double width;

  double get height => width * 1.5;

  @override
  Widget build(BuildContext context) {
    // A cover is an image: it ignores Dynamic Type so it never overflows its
    // own frame, and it renders identically inside the share card.
    final fallback = MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.noScaling),
      child: _TypographicCover(
        bookId: bookId,
        title: title,
        author: author,
        width: width,
        height: height,
      ),
    );
    final url = coverUrl;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(border: pixelBorder()),
      clipBehavior: Clip.hardEdge,
      child: url == null
          ? fallback
          : CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (_, _) => fallback,
              errorWidget: (_, _, _) => fallback,
              fadeInDuration: Duration.zero,
              fadeOutDuration: Duration.zero,
            ),
    );
  }
}

class _TypographicCover extends StatelessWidget {
  const _TypographicCover({
    required this.bookId,
    required this.title,
    required this.author,
    required this.width,
    required this.height,
  });

  final String bookId;
  final String title;
  final String author;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final color = spineColorFor(bookId);
    final light = color.computeLuminance() > 0.4;
    final ink = light ? Tokens.inkOnCream : Tokens.cream;
    final scale = width / 96;
    return Container(
      color: color,
      padding: EdgeInsets.all(8 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 14 * scale,
            height: 14 * scale,
            decoration: BoxDecoration(
              color: Tokens.outline,
              border: pixelBorder(),
            ),
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: pix(size: 12 * scale, weight: FontWeight.w600, color: ink),
          ),
          SizedBox(height: 4 * scale),
          Text(
            author,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: body(size: 9 * scale, color: ink.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}
