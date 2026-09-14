import 'package:booksbound_app/providers/book_provider.dart';
import 'package:booksbound_app/utils/haptics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SortSheet {
  void showSortSheet(BuildContext context) {
    Haptics.light();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(100),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Sort by',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              _sortTile(context, 'Price: Low to High', SortType.priceLow),
              _sortTile(context, 'Price: High to Low', SortType.priceHigh),
              _sortTile(context, 'Newest Arrivals', SortType.newest),
              _sortTile(context, 'Popularity', SortType.popularity),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _sortTile(BuildContext context, String title, SortType type) {
    return Semantics(
      label: 'Sort by $title',
      button: true,
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Haptics.selection();
          context.read<BookProvider>().sortBy(type);
          Navigator.pop(context);
        },
      ),
    );
  }
}
