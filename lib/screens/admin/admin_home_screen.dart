import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/admin_provider.dart';
import 'manage_books_screen.dart';
import 'manage_listings_screen.dart';
import 'manage_reviews_screen.dart';
import 'manage_users_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AdminProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final stats = admin.stats;

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: admin.loading && stats == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => admin.load(),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (stats != null)
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.5,
                      children: [
                        _StatCard(label: 'Users', value: stats.users, icon: Icons.people_outline_rounded),
                        _StatCard(label: 'Books', value: stats.books, icon: Icons.menu_book_outlined),
                        _StatCard(label: 'Reviews', value: stats.reviews, icon: Icons.rate_review_outlined),
                        _StatCard(label: 'Listings', value: stats.listings, icon: Icons.storefront_outlined),
                        _StatCard(label: 'Active Loans', value: stats.activeLoans, icon: Icons.swap_horiz_rounded, wide: true),
                      ],
                    ),
                  const SizedBox(height: 26),
                  const Text('Manage', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: AppColors.brown900)),
                  const SizedBox(height: 12),
                  _ManageTile(
                    icon: Icons.people_outline_rounded,
                    label: 'Users',
                    subtitle: 'Suspend accounts, change roles',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageUsersScreen())),
                  ),
                  _ManageTile(
                    icon: Icons.menu_book_outlined,
                    label: 'Books',
                    subtitle: 'Remove books from the catalog',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageBooksScreen())),
                  ),
                  _ManageTile(
                    icon: Icons.storefront_outlined,
                    label: 'Listings',
                    subtitle: 'Remove marketplace listings',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageListingsScreen())),
                  ),
                  _ManageTile(
                    icon: Icons.rate_review_outlined,
                    label: 'Reviews',
                    subtitle: 'Moderate or remove reviews',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageReviewsScreen())),
                  ),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final bool wide;
  const _StatCard({required this.label, required this.value, required this.icon, this.wide = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.brown500),
          const SizedBox(height: 8),
          Text('$value', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.brown900)),
          Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.grayText)),
        ],
      ),
    );
  }
}

class _ManageTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  const _ManageTile({required this.icon, required this.label, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(backgroundColor: AppColors.tan100, foregroundColor: AppColors.brown500, child: Icon(icon, size: 20)),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.brown900)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12.5)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.grayText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
