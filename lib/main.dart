import 'package:booksbound_app/core/theme/app_theme.dart';
import 'package:booksbound_app/features/admin/analytics/providers/admin_analytics_provider.dart';
import 'package:booksbound_app/features/admin/manage_users/providers/admin_users_provider.dart';
import 'package:booksbound_app/providers/book_provider.dart';
import 'package:booksbound_app/providers/cart_provider.dart';
import 'package:booksbound_app/providers/category_provider.dart';
import 'package:booksbound_app/providers/ratings_provider.dart';
import 'package:booksbound_app/providers/reviews_provider.dart';
import 'package:booksbound_app/providers/theme_provider.dart';
import 'package:booksbound_app/providers/user_provider.dart';
import 'package:booksbound_app/providers/user_auth_provider.dart';
import 'package:booksbound_app/providers/wishlist_provider.dart';
import 'package:booksbound_app/routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('themeMode');
  ThemeMode initialTheme = ThemeMode.system;
  if (savedTheme == 'dark') initialTheme = ThemeMode.dark;
  if (savedTheme == 'light') initialTheme = ThemeMode.light;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(initialTheme: initialTheme)),
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => UserAuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => RatingsProvider()),
        ChangeNotifierProvider(create: (_) => ReviewsProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => AdminUsersProvider()),
        ChangeNotifierProvider(create: (_) => AdminAnalyticsProvider()),
      ],

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: AppRoutes.splash,
          routes: AppRoutes.routes,
          onGenerateRoute: AppRoutes.generateRoute,
        );
      },
    );
  }
}
