import 'package:booksbound_app/widgets/book_card_skeleton.dart';
import 'package:booksbound_app/widgets/skeleton.dart';
import 'package:flutter/material.dart';

class HomeScreenSkeleton extends StatelessWidget {
  const HomeScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          // Categories Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Skeleton(width: 120, height: 22, radius: 4),
                Skeleton(width: 60, height: 16, radius: 4),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Category Chips Row
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, _) =>
                  const Skeleton(width: 90, height: 38, radius: 20),
            ),
          ),
          const SizedBox(height: 20),
          // Section 1 Header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Skeleton(width: 130, height: 22, radius: 4),
          ),
          const SizedBox(height: 12),
          // Carousel Skeleton
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 4,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, _) => Container(
                width: 140,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(8),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Skeleton(
                        width: double.infinity,
                        height: double.infinity,
                        radius: 10,
                      ),
                    ),
                    SizedBox(height: 8),
                    Skeleton(width: 100, height: 12, radius: 4),
                    SizedBox(height: 6),
                    Skeleton(width: 60, height: 10, radius: 4),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Section 2 Header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Skeleton(width: 110, height: 22, radius: 4),
          ),
          const SizedBox(height: 12),
          // Grid Skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.62,
              ),
              itemCount: 4,
              itemBuilder: (_, _) => const BookCardSkeleton(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
