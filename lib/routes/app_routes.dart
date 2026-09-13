import 'package:booksbound_app/features/auth/login_screen.dart';
import 'package:booksbound_app/features/auth/register_screen.dart';
import 'package:booksbound_app/features/admin/admin_panel_screen.dart';
import 'package:booksbound_app/features/admin/analytics/admin_analytics_screen.dart';
import 'package:booksbound_app/features/admin/manage_books/manage_books_screen.dart';
import 'package:booksbound_app/features/admin/manage_orders/manage_orders_screen.dart';
import 'package:booksbound_app/features/admin/manage_reviews/reviews_screen.dart';
import 'package:booksbound_app/features/admin/manage_reviews/reviewsbooks_screen.dart';
import 'package:booksbound_app/features/admin/manage_users/manage_users_screen.dart';
import 'package:booksbound_app/features/book_details/book_details_screen.dart';
import 'package:booksbound_app/features/cart/checkout_screen.dart';
import 'package:booksbound_app/features/change_password/change_password_screen.dart';
import 'package:booksbound_app/features/edit_profile/edit_profile_screen.dart';
import 'package:booksbound_app/features/layout/layout.dart';
import 'package:booksbound_app/features/splash/splash_screen.dart';
import 'package:booksbound_app/features/wishlist/wishlist_screen.dart';
import 'package:booksbound_app/models/book_model.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const splash = '/';
  static const main = '/main';
  static const bookDetails = '/book/book-details';
  static const register = '/register';
  static const login = '/login';
  static const editProfile = '/profile/edit-profile';
  static const changePassword = '/profile/change-password';
  static const wishlist = '/wishlist';
  static const checkout = '/cart/checkout';
  static const adminPanel = '/admin-panel';
  static const manageBooks = '/admin-panel/manage-books';
  static const manageOrders = '/admin-panel/manage-orders';
  static const manageReviewsBooks = "/admin-panel/manage-reviews-books";
  static const manageReviews =
      '/admin-panel/manage-reviews-books/manage-reviews';
  static const manageUsers = "/admin-panel/manage-users";
  static const analytics = "/admin-panel/analytics";

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    main: (context) => const MainLayout(),
    register: (context) => const RegisterScreen(),
    login: (context) => const LoginScreen(),
    adminPanel: (context) => const AdminPanelScreen(),
    manageBooks: (context) => const ManageBooksScreen(),
    manageOrders: (context) => const ManageOrdersScreen(),
    manageReviewsBooks: (context) => const ReviewsbooksScreen(),
    manageUsers: (context) => const AdminUsersScreen(),
    analytics: (context) => const AdminAnalyticsScreen(),
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case bookDetails:
        final book = settings.arguments as Book;
        return MaterialPageRoute(builder: (_) => BookDetailsScreen(book: book));

      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      case changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());

      case wishlist:
        return MaterialPageRoute(builder: (_) => const WishlistScreen());

      case checkout:
        return MaterialPageRoute(builder: (_) => const CheckoutScreen());

      case adminPanel:
        return MaterialPageRoute(builder: (_) => const AdminPanelScreen());

      case manageBooks:
        return MaterialPageRoute(builder: (_) => const ManageBooksScreen());

      case manageOrders:
        return MaterialPageRoute(builder: (_) => const ManageOrdersScreen());

      case manageReviewsBooks:
        return MaterialPageRoute(builder: (_) => const ReviewsbooksScreen());

      case manageReviews:
        final bookId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ReviewsAdminScreen(bookId: bookId),
        );
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}

// ignore: camel_case_types
typedef appRoutes = AppRoutes;
