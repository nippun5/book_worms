import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../models/book_listing.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../widgets/common.dart';
import '../../widgets/listing_card.dart';
import 'listing_detail_screen.dart';
import 'post_listing_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final me = context.read<AuthProvider>().user;
      if (me != null) context.read<MarketplaceProvider>().load(me);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AuthProvider>().user;
    final market = context.watch<MarketplaceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Browse'), Tab(text: 'My Listings')],
        ),
      ),
      body: me == null
          ? const SizedBox.shrink()
          : TabBarView(
              controller: _tabController,
              children: [
                _BrowseTab(market: market, me: me),
                _MyListingsTab(market: market, me: me),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const PostListingScreen()));
          if (me != null) await market.load(me);
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('List a Book'),
        backgroundColor: AppColors.brown500,
      ),
    );
  }
}

class _BrowseTab extends StatelessWidget {
  final MarketplaceProvider market;
  final AppUser me;
  const _BrowseTab({required this.market, required this.me});

  @override
  Widget build(BuildContext context) {
    final items = market.visible;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: Row(
            children: [
              _FilterChip(label: 'All', selected: market.filter == MarketFilter.all, onTap: () => market.setFilter(MarketFilter.all)),
              const SizedBox(width: 10),
              _FilterChip(
                  label: 'For Sale', selected: market.filter == MarketFilter.sale, onTap: () => market.setFilter(MarketFilter.sale)),
              const SizedBox(width: 10),
              _FilterChip(
                  label: 'For Loan', selected: market.filter == MarketFilter.loan, onTap: () => market.setFilter(MarketFilter.loan)),
            ],
          ),
        ),
        Expanded(
          child: market.loading
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
                  ? const EmptyState(
                      icon: Icons.storefront_outlined,
                      title: 'Nothing listed here yet',
                      message: 'Be the first to list a book for sale or loan.',
                    )
                  : RefreshIndicator(
                      onRefresh: () => market.load(me),
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        itemCount: items.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.62,
                        ),
                        itemBuilder: (_, i) {
                          final view = items[i];
                          return ListingCard(
                            view: view,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ListingDetailScreen(listingId: view.listing.id!)),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}

class _MyListingsTab extends StatelessWidget {
  final MarketplaceProvider market;
  final AppUser me;
  const _MyListingsTab({required this.market, required this.me});

  @override
  Widget build(BuildContext context) {
    final items = market.mine;
    if (market.loading) return const Center(child: CircularProgressIndicator());
    if (items.isEmpty) {
      return const EmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'You have no listings',
        message: 'List a book you own to sell or loan it out.',
      );
    }
    return RefreshIndicator(
      onRefresh: () => market.load(me),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final view = items[i];
          final statusLabel = switch (view.listing.status) {
            ListingStatus.available => 'Available',
            ListingStatus.pending => 'Pending',
            ListingStatus.unavailable => 'Unavailable',
          };
          return ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            leading: Container(
              width: 40,
              height: 56,
              decoration: BoxDecoration(color: Color(view.book.coverColorValue), borderRadius: BorderRadius.circular(6)),
            ),
            title: Text(view.book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('${view.listing.type == ListingType.loan ? "Loan" : "Sale"} · $statusLabel'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ListingDetailScreen(listingId: view.listing.id!)),
            ),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.brown500 : AppColors.tan100,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(label,
            style: TextStyle(color: selected ? Colors.white : AppColors.brown700, fontWeight: FontWeight.w600, fontSize: 13.5)),
      ),
    );
  }
}
