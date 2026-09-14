import 'package:booksbound_app/widgets/skeleton.dart';
import 'package:flutter/material.dart';

class BookCardSkeleton extends StatelessWidget {
  const BookCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Skeleton(
              width: double.infinity,
              height: double.infinity,
              radius: 12,
            ),
          ),
          const SizedBox(height: 8),
          const Skeleton(width: 120, height: 14, radius: 4),
          const SizedBox(height: 6),
          const Skeleton(width: 80, height: 10, radius: 4),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Skeleton(width: 50, height: 12, radius: 4),
              Skeleton(width: 40, height: 12, radius: 4),
            ],
          ),
        ],
      ),
    );
  }
}

class BookListTileSkeleton extends StatelessWidget {
  const BookListTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Skeleton(width: 55, height: 75, radius: 8),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(width: 180, height: 16, radius: 4),
                SizedBox(height: 8),
                Skeleton(width: 110, height: 12, radius: 4),
                SizedBox(height: 8),
                Skeleton(width: 70, height: 14, radius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
