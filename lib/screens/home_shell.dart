import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/catalog_provider.dart';
import 'dashboard/dashboard_screen.dart';
import 'marketplace/marketplace_screen.dart';
import 'loans/my_loans_screen.dart';
import 'profile/profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _screens = [
    DashboardScreen(),
    MarketplaceScreen(),
    MyLoansScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Warm the shared book catalog once when the app shell mounts.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront_rounded), label: 'Market'),
          NavigationDestination(
              icon: Icon(Icons.swap_horiz_rounded), selectedIcon: Icon(Icons.swap_horiz_rounded), label: 'Loans'),
          NavigationDestination(
              icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
