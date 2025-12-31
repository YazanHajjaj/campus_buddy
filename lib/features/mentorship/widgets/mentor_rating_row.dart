import 'package:flutter/material.dart';

class MentorRatingRow extends StatelessWidget {
  final double ratingAvg;
  final int ratingCount;
  final double iconSize;
  final TextStyle? textStyle;

  const MentorRatingRow({
    super.key,
    required this.ratingAvg,
    required this.ratingCount,
    this.iconSize = 16,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (ratingCount == 0) {
      return Text(
        'No ratings yet',
        style: textStyle ??
            Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.black54),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          size: iconSize,
          color: Colors.amber,
        ),
        const SizedBox(width: 4),
        Text(
          ratingAvg.toStringAsFixed(1),
          style: textStyle ??
              Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(width: 6),
        Text(
          '($ratingCount)',
          style: textStyle ??
              Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.black54),
        ),
      ],
    );
  }
}