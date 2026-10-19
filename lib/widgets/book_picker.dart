import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_colors.dart';
import '../models/book.dart';
import '../providers/catalog_provider.dart';

/// Holds the "which book?" state shared by the Write Review and List a Book
/// screens: either an existing catalog book, or details for a new one.
class BookPickerController extends ChangeNotifier {
  Book? selected;
  bool addingNew = false;
  final titleCtrl = TextEditingController();
  final authorCtrl = TextEditingController();
  final genreCtrl = TextEditingController();

  BookPickerController({this.selected});

  void select(Book book) {
    selected = book;
    addingNew = false;
    notifyListeners();
  }

  void startNew() {
    selected = null;
    addingNew = true;
    notifyListeners();
  }

  void backToExisting() {
    addingNew = false;
    notifyListeners();
  }

  String? validate() {
    if (addingNew) {
      if (titleCtrl.text.trim().isEmpty) return 'Enter the book title.';
      if (authorCtrl.text.trim().isEmpty) return 'Enter the author.';
      return null;
    }
    return selected == null ? 'Choose a book first.' : null;
  }

  Future<Book> resolve(CatalogProvider catalog, int userId) async {
    if (addingNew) {
      return catalog.findOrCreate(
        title: titleCtrl.text,
        author: authorCtrl.text,
        genre: genreCtrl.text,
        userId: userId,
      );
    }
    return selected!;
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    authorCtrl.dispose();
    genreCtrl.dispose();
    super.dispose();
  }
}

class BookPickerField extends StatelessWidget {
  final BookPickerController controller;
  final bool locked;

  const BookPickerField({super.key, required this.controller, this.locked = false});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.addingNew) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller.titleCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Book title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.authorCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Author'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.genreCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Genre (optional)'),
              ),
              TextButton(
                onPressed: controller.backToExisting,
                child: const Text('Pick an existing book instead'),
              ),
            ],
          );
        }

        final book = controller.selected;
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: locked ? null : () => _openSheet(context),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Book',
              suffixIcon: locked ? null : const Icon(Icons.expand_more_rounded),
            ),
            child: Text(
              book == null ? 'Choose a book' : '${book.title} — ${book.author}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: book == null ? AppColors.grayText : AppColors.brown900),
            ),
          ),
        );
      },
    );
  }

  void _openSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _BookSheet(controller: controller),
    );
  }
}

class _BookSheet extends StatefulWidget {
  final BookPickerController controller;
  const _BookSheet({required this.controller});

  @override
  State<_BookSheet> createState() => _BookSheetState();
}

class _BookSheetState extends State<_BookSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final books = context.watch<CatalogProvider>().books.where((b) {
      final q = _query.toLowerCase();
      return q.isEmpty || b.title.toLowerCase().contains(q) || b.author.toLowerCase().contains(q);
    }).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(color: AppColors.tan100, borderRadius: BorderRadius.circular(4)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                autofocus: false,
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  hintText: 'Search by title or author',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.brown500,
                child: Icon(Icons.add_rounded, color: Colors.white),
              ),
              title: const Text('Add a new book', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                widget.controller.startNew();
                Navigator.pop(context);
              },
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: books.length,
                itemBuilder: (_, i) {
                  final b = books[i];
                  return ListTile(
                    leading: Container(
                      width: 36,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color(b.coverColorValue),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    title: Text(b.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(b.author),
                    onTap: () {
                      widget.controller.select(b);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
