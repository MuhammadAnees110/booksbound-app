import 'package:booksbound_app/features/cart/cart_screen.dart';
import 'package:booksbound_app/features/home/home_screen.dart';
import 'package:booksbound_app/features/profile/profile_screen.dart';
import 'package:booksbound_app/features/search/search_screen.dart';
import 'package:booksbound_app/providers/user_provider.dart';
import 'package:booksbound_app/routes/app_routes.dart';
import 'package:booksbound_app/widgets/brand.dart';
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
    ProfileScreen(),
  ];

  List<PersistentBottomNavBarItem> _navBarsItems() => [
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.home),
      title: "Home",
      activeColorPrimary: Colors.black,
      inactiveColorPrimary: Colors.grey,
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.search),
      title: "Search",
      activeColorPrimary: Colors.black,
      inactiveColorPrimary: Colors.grey,
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.shopping_cart),
      title: "Cart",
      activeColorPrimary: Colors.black,
      inactiveColorPrimary: Colors.grey,
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.person),
      title: "Profile",
      activeColorPrimary: Colors.black,
      inactiveColorPrimary: Colors.grey,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset("images/logo.png", fit: BoxFit.contain),
        ),
        title: const Brand(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamed(appRoutes.categories);
            },
            icon: const Icon(Icons.category_outlined),
            tooltip: "Categories",
          ),
          IconButton(
            onPressed: () {
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamed(appRoutes.wishlist);
            },
            icon: const Icon(Icons.favorite_border),
          ),
          Consumer<ProfileProvider>(
            builder: (context, provider, _) {
              if (provider.isAdmin) {
                return IconButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pushNamed(appRoutes.adminPanel);
                  },
                  icon: const Icon(Icons.dashboard),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        confineToSafeArea: true,
        backgroundColor: Colors.white,
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
    );
  }
}
