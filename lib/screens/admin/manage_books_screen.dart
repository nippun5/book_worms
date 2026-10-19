import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/admin_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../widgets/common.dart';

class ManageBooksScreen extends StatelessWidget {
  const ManageBooksScreen({super.key});

  Future<void> _delete(BuildContext context, int bookId, String title) async {
    final ok = await confirmDialog(
      context,
      title: 'Remove "$title"?',
      message: 'This also removes every review, listing and loan tied to this book. This can\'t be undone.',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (!ok) return;
    await context.read<AdminProvider>().deleteBook(bookId);
    if (context.mounted) await context.read<CatalogProvider>().load();
    if (context.mounted) showSnack(context, 'Book removed.');
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Books')),
      body: admin.books.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: admin.books.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final b = admin.books[i];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 56,
                        decoration: BoxDecoration(color: Color(b.coverColorValue), borderRadius: BorderRadius.circular(6)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text('${b.author} · ${b.genre}', style: const TextStyle(fontSize: 12.5, color: AppColors.grayText)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.red),
                        onPressed: () => _delete(context, b.id!, b.title),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
