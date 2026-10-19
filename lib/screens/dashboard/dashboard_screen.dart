import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/feed_provider.dart';
import '../../widgets/common.dart';
import '../../widgets/review_card.dart';
import '../book/book_detail_screen.dart';
import '../book/write_review_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _tabs = const [FeedTab.trending, FeedTab.latest, FeedTab.mine];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final me = context.read<AuthProvider>().user;
      if (me != null) context.read<FeedProvider>().load(me);
    });
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final me = context.read<AuthProvider>().user;
      if (me != null) context.read<FeedProvider>().setTab(_tabs[_tabController.index], me);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openSearch() async {
    final catalog = context.read<CatalogProvider>();
    final controller = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        var query = '';
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.7,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: controller,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: 'Search books or authors',
                          prefixIcon: Icon(Icons.search_rounded),
                        ),
                        onChanged: (v) => setSheetState(() => query = v),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: FutureBuilder(
                        future: catalog.search(query),
                        builder: (context, snapshot) {
                          final results = snapshot.data ?? const [];
                          final shown = query.isEmpty ? catalog.books : results;
                          if (shown.isEmpty) {
                            return const EmptyState(
                              icon: Icons.search_off_rounded,
                              title: 'No books found',
                              message: 'Try a different title or author.',
                            );
                          }
                          return ListView.builder(
                            itemCount: shown.length,
                            itemBuilder: (_, i) {
                              final b = shown[i];
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
                                  Navigator.pop(ctx);
                                  Navigator.push(
                                      context, MaterialPageRoute(builder: (_) => BookDetailScreen(bookId: b.id!)));
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AuthProvider>().user;
    final feed = context.watch<FeedProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Worms'),
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: _openSearch),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Trending'), Tab(text: 'Latest'), Tab(text: 'Mine')],
        ),
      ),
      body: me == null
          ? const SizedBox.shrink()
          : RefreshIndicator(
              onRefresh: () => feed.load(me),
              child: feed.loading
                  ? const Center(child: CircularProgressIndicator())
                  : feed.items.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 80),
                            EmptyState(
                              icon: Icons.rate_review_outlined,
                              title: 'No reviews yet',
                              message: 'Be the first to review a book on this tab.',
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          itemCount: feed.items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (_, i) {
                            final item = feed.items[i];
                            return ReviewCard(
                              item: item,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => BookDetailScreen(bookId: item.book.id!)),
                              ),
                              onLike: () => feed.toggleLike(item, me),
                            );
                          },
                        ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WriteReviewScreen())),
        icon: const Icon(Icons.edit_rounded),
        label: const Text('Write a Review'),
        backgroundColor: AppColors.brown500,
      ),
    );
  }
}
