import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/catalog_provider.dart';
import 'providers/feed_provider.dart';
import 'providers/marketplace_provider.dart';
import 'providers/loan_provider.dart';
import 'providers/admin_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_shell.dart';

void main() {
  runApp(const BookWormsApp());
}

class BookWormsApp extends StatelessWidget {
  const BookWormsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => CatalogProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
        ChangeNotifierProvider(create: (_) => MarketplaceProvider()),
        ChangeNotifierProvider(create: (_) => LoanProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'Book Worms',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AuthGate(),
      ),
    );
  }
}

/// Shows a splash while the session/demo data loads, then routes to the
/// login flow or straight into the app if a session was restored.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.initializing) return const SplashScreen();
    if (!auth.isLoggedIn) return const LoginScreen();
    return const HomeShell();
  }
}
