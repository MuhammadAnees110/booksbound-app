import 'package:booksbound_app/features/admin/admin_panel_screen.dart';
import 'package:booksbound_app/features/cart/cart_screen.dart';
import 'package:booksbound_app/features/categories/categories_screen.dart';
import 'package:booksbound_app/features/home/home_screen.dart';
import 'package:booksbound_app/features/profile/profile_screen.dart';
import 'package:booksbound_app/features/search/search_screen.dart';
import 'package:booksbound_app/features/wishlist/wishlist_screen.dart';
import 'package:booksbound_app/providers/user_provider.dart';
import 'package:booksbound_app/routes/app_routes.dart';
import 'package:booksbound_app/widgets/brand.dart';
import 'package:booksbound_app/widgets/offline_banner.dart';
import 'package:booksbound_app/utils/haptics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late final PersistentTabController _controller;
  BuildContext? _tabContext;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);

    // Safely trigger role load after frame build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        context.read<ProfileProvider>().loadRole(uid);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Widget> _buildScreens() => [
    const HomeScreen(),
    const SearchScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  RouteAndNavigatorSettings get _routeSettings => RouteAndNavigatorSettings(
    routes: AppRoutes.routes,
    onGenerateRoute: AppRoutes.generateRoute,
  );

  List<PersistentBottomNavBarItem> _navBarsItems() => [
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.home),
      title: "Home",
      activeColorPrimary: Colors.black,
      inactiveColorPrimary: Colors.grey,
      routeAndNavigatorSettings: _routeSettings,
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.search),
      title: "Search",
      activeColorPrimary: Colors.black,
      inactiveColorPrimary: Colors.grey,
      routeAndNavigatorSettings: _routeSettings,
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.shopping_cart),
      title: "Cart",
      activeColorPrimary: Colors.black,
      inactiveColorPrimary: Colors.grey,
      routeAndNavigatorSettings: _routeSettings,
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.person),
      title: "Profile",
      activeColorPrimary: Colors.black,
      inactiveColorPrimary: Colors.grey,
      routeAndNavigatorSettings: _routeSettings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.contain,
            errorBuilder: (ctx, error, _) =>
                const Icon(Icons.menu_book, size: 28),
          ),
        ),
        title: const Brand(),
        elevation: 1,
        actions: [
          IconButton(
            onPressed: () {
              final targetContext = _tabContext ?? context;
              PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                targetContext,
                settings: const RouteSettings(name: appRoutes.categories),
                screen: const CategoriesScreen(),
                withNavBar: true,
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            },
            icon: const Icon(Icons.category_outlined),
            tooltip: "Categories",
          ),
          IconButton(
            onPressed: () {
              final targetContext = _tabContext ?? context;
              PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                targetContext,
                settings: const RouteSettings(name: appRoutes.wishlist),
                screen: const WishlistScreen(),
                withNavBar: true,
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            },
            icon: const Icon(Icons.favorite_border),
            tooltip: "Wishlist",
          ),
          Consumer<ProfileProvider>(
            builder: (context, provider, _) {
              if (provider.isAdmin) {
                return IconButton(
                  onPressed: () {
                    final targetContext = _tabContext ?? context;
                    PersistentNavBarNavigator.pushNewScreenWithRouteSettings(
                      targetContext,
                      settings: const RouteSettings(name: appRoutes.adminPanel),
                      screen: const AdminPanelScreen(),
                      withNavBar: true,
                      pageTransitionAnimation: PageTransitionAnimation.cupertino,
                    );
                  },
                  icon: const Icon(Icons.dashboard),
                  tooltip: "Admin Panel",
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: PersistentTabView(
              context,
              controller: _controller,
              screens: _buildScreens(),
              items: _navBarsItems(),
              selectedTabScreenContext: (context) {
                _tabContext = context;
              },
              onItemSelected: (index) {
                Haptics.light();
              },
              confineToSafeArea: true,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xEE1C1C1E)
                  : const Color(0xEEFFFFFF),
              handleAndroidBackButtonPress: true,
              navBarHeight: kBottomNavigationBarHeight,
              animationSettings: const NavBarAnimationSettings(
                screenTransitionAnimation: ScreenTransitionAnimationSettings(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  animateTabTransition: true,
                  screenTransitionAnimationType: ScreenTransitionAnimationType.slide,
                ),
              ),
              navBarStyle: NavBarStyle.neumorphic,
            ),
          ),
        ],
      ),
    );
  }
}
