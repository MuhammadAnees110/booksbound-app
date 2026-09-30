import 'package:booksbound_app/features/auth/forgot_password_screen.dart';
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
import 'package:booksbound_app/features/categories/categories_screen.dart';
import 'package:booksbound_app/features/categories/category_books_screen.dart';
import 'package:booksbound_app/features/change_password/change_password_screen.dart';
import 'package:booksbound_app/features/edit_profile/edit_profile_screen.dart';
import 'package:booksbound_app/features/layout/layout.dart';
import 'package:booksbound_app/features/profile/delete_account_screen.dart';
import 'package:booksbound_app/features/splash/splash_screen.dart';
import 'package:booksbound_app/features/wishlist/wishlist_screen.dart';
import 'package:booksbound_app/features/checkout/order_success_screen.dart';
import 'package:booksbound_app/models/book_model.dart';
import 'package:booksbound_app/models/category_model.dart';
import 'package:booksbound_app/utils/page_transitions.dart';
import 'package:booksbound_app/widgets/admin_route_guard.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const splash = '/';
  static const main = '/main';
  static const bookDetails = '/book/book-details';
  static const register = '/register';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const editProfile = '/profile/edit-profile';
  static const changePassword = '/profile/change-password';
  static const wishlist = '/wishlist';
  static const checkout = '/cart/checkout';
  static const categories = '/categories';
  static const categoryBooks = '/categories/books';
  static const adminPanel = '/admin-panel';
  static const manageBooks = '/admin-panel/manage-books';
  static const manageOrders = '/admin-panel/manage-orders';
  static const manageReviewsBooks = "/admin-panel/manage-reviews-books";
  static const manageReviews =
      '/admin-panel/manage-reviews-books/manage-reviews';
  static const manageUsers = "/admin-panel/manage-users";
  static const analytics = "/admin-panel/analytics";
  static const deleteAccount = '/profile/delete-account';
  static const orderSuccess = '/checkout/order-success';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    main: (context) => const MainLayout(),
    register: (context) => const RegisterScreen(),
    login: (context) => const LoginScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    categories: (context) => const CategoriesScreen(),
    adminPanel: (context) => const AdminRouteGuard(child: AdminPanelScreen()),
    manageBooks: (context) => const AdminRouteGuard(child: ManageBooksScreen()),
    manageOrders: (context) =>
        const AdminRouteGuard(child: ManageOrdersScreen()),
    manageReviewsBooks: (context) =>
        const AdminRouteGuard(child: ReviewsbooksScreen()),
    manageUsers: (context) => const AdminRouteGuard(child: AdminUsersScreen()),
    analytics: (context) =>
        const AdminRouteGuard(child: AdminAnalyticsScreen()),
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case bookDetails:
        final argument = settings.arguments;
        if (argument is! Book) return _notFoundRoute(settings);
        return SlideRightRoute(
          page: BookDetailsScreen(book: argument),
          settings: settings,
        );

      case editProfile:
        return SlideRightRoute(
          page: const EditProfileScreen(),
          settings: settings,
        );

      case forgotPassword:
        return SlideRightRoute(
          page: const ForgotPasswordScreen(),
          settings: settings,
        );

      case changePassword:
        return SlideRightRoute(
          page: const ChangePasswordScreen(),
          settings: settings,
        );

      case wishlist:
        return FadeRoute(page: const WishlistScreen(), settings: settings);

      case categories:
        return FadeRoute(page: const CategoriesScreen(), settings: settings);

      case categoryBooks:
        final argument = settings.arguments;
        if (argument is! CategoryModel) return _notFoundRoute(settings);
        return SlideRightRoute(
          page: CategoryBooksScreen(category: argument),
          settings: settings,
        );

      case checkout:
        return SlideRightRoute(
          page: const CheckoutScreen(),
          settings: settings,
        );

      case adminPanel:
        return FadeRoute(
          page: const AdminRouteGuard(child: AdminPanelScreen()),
          settings: settings,
        );

      case manageBooks:
        return SlideRightRoute(
          page: const AdminRouteGuard(child: ManageBooksScreen()),
          settings: settings,
        );

      case manageOrders:
        return SlideRightRoute(
          page: const AdminRouteGuard(child: ManageOrdersScreen()),
          settings: settings,
        );

      case manageReviewsBooks:
        return SlideRightRoute(
          page: const AdminRouteGuard(child: ReviewsbooksScreen()),
          settings: settings,
        );

      case manageReviews:
        final bookId = settings.arguments;
        if (bookId is! String || bookId.isEmpty) {
          return _notFoundRoute(settings);
        }
        return SlideRightRoute(
          page: AdminRouteGuard(child: ReviewsAdminScreen(bookId: bookId)),
          settings: settings,
        );

      case manageUsers:
        return SlideRightRoute(
          page: const AdminRouteGuard(child: AdminUsersScreen()),
          settings: settings,
        );

      case analytics:
        return FadeRoute(
          page: const AdminRouteGuard(child: AdminAnalyticsScreen()),
          settings: settings,
        );

      case deleteAccount:
        return SlideRightRoute(
          page: const DeleteAccountScreen(),
          settings: settings,
        );

      case orderSuccess:
        final args = settings.arguments;
        if (args is! Map<String, dynamic> ||
            args['orderId'] is! String ||
            args['totalAmount'] is! num) {
          return _notFoundRoute(settings);
        }
        return FadeRoute(
          page: OrderSuccessScreen(
            orderId: args['orderId'] as String,
            totalAmount: (args['totalAmount'] as num).toDouble(),
          ),
          settings: settings,
        );

      default:
        return FadeRoute(
          page: const Scaffold(body: Center(child: Text('Route not found'))),
          settings: settings,
        );
    }
  }

  static Route<dynamic> _notFoundRoute(RouteSettings settings) {
    return FadeRoute(
      page: const Scaffold(body: Center(child: Text('Route not found'))),
      settings: settings,
    );
  }
}

// ignore: camel_case_types
typedef appRoutes = AppRoutes;
