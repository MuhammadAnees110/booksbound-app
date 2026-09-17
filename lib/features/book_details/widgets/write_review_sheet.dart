import 'package:booksbound_app/providers/ratings_provider.dart';
import 'package:booksbound_app/providers/reviews_provider.dart';
import 'package:booksbound_app/utils/haptics.dart';
import 'package:booksbound_app/widgets/error_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WriteReviewSheet extends StatefulWidget {
  final String bookId;

  const WriteReviewSheet({super.key, required this.bookId});

  @override
  State<WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<WriteReviewSheet> {
  final _commentController = TextEditingController();
  int _selectedRating = 5;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    Haptics.light();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a review comment.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final reviewResult = await context.read<ReviewsProvider>().addReview(
          bookId: widget.bookId,
          comment: comment,
        );

    if (!reviewResult.isSuccess) {
      if (mounted) {
        ErrorPresenter.show(context, reviewResult);
        setState(() => _isSubmitting = false);
      }
      return;
    }

    if (mounted) {
      final ratingResult = await context.read<RatingsProvider>().rateBook(
            widget.bookId,
            _selectedRating.toDouble(),
          );
      if (!mounted) return;
      if (!ratingResult.isSuccess) {
        ErrorPresenter.show(context, ratingResult);
      }
    }

    if (!mounted) return;

    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Review submitted successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(100),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Write a Review',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Close',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Your Rating:',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              return Semantics(
                label: 'Rate $starValue out of 5 stars',
                button: true,
                child: IconButton(
                  tooltip: 'Rate $starValue ${starValue == 1 ? "star" : "stars"}',
                  icon: Icon(
                    starValue <= _selectedRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 36,
                  ),
                  onPressed: () {
                    Haptics.selection();
                    setState(() => _selectedRating = starValue);
                  },
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commentController,
            maxLength: 500,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Share your honest thoughts about this book...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              helperText: 'Max 500 characters',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReview,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Submit Review',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
