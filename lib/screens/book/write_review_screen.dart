import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../models/book.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/feed_provider.dart';
import '../../widgets/book_picker.dart';
import '../../widgets/common.dart';
import '../../widgets/star_rating.dart';

class WriteReviewScreen extends StatefulWidget {
  final Book? presetBook;
  const WriteReviewScreen({super.key, this.presetBook});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  late final BookPickerController _picker;
  final _textCtrl = TextEditingController();
  int _rating = 0;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _picker = BookPickerController(selected: widget.presetBook);
  }

  @override
  void dispose() {
    _picker.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    final bookError = _picker.validate();
    if (bookError != null) {
      setState(() => _error = bookError);
      return;
    }
    if (_rating == 0) {
      setState(() => _error = 'Tap a star to rate this book.');
      return;
    }
    if (_textCtrl.text.trim().length < 8) {
      setState(() => _error = 'Write a few words about the book.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final me = context.read<AuthProvider>().user!;
      final catalog = context.read<CatalogProvider>();
      final book = await _picker.resolve(catalog, me.id!);
      await context.read<FeedProvider>().addReview(
            me: me,
            bookId: book.id!,
            rating: _rating,
            text: _textCtrl.text,
          );
      if (!mounted) return;
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = widget.presetBook != null;
    return Scaffold(
      appBar: AppBar(title: const Text('Write a Review')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookPickerField(controller: _picker, locked: locked),
              const SizedBox(height: 22),
              const Text('Your rating', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.brown900)),
              const SizedBox(height: 6),
              StarRatingInput(value: _rating, onChanged: (v) => setState(() => _rating = v)),
              const SizedBox(height: 14),
              TextField(
                controller: _textCtrl,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'What did you think?',
                  alignLabelWithHint: true,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: AppColors.red, fontSize: 13)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                        )
                      : const Text('Post Review'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
