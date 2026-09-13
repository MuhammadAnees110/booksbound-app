import 'package:booksbound_app/routes/app_routes.dart';
import 'package:booksbound_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final Future<LottieComposition> _lottie;
  final AuthService _authService = AuthService();

  Future<void> _checkAuth() async {
    final isLoggedIn = await _authService.isLoggedIn();
    await Future.delayed(Duration(seconds: 3));

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, appRoutes.main);
    } else {
      Navigator.pushReplacementNamed(context, appRoutes.login);
    }
  }

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _lottie = AssetLottie("lottie/books.json").load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: FutureBuilder<LottieComposition>(
          future: _lottie,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(); // no flicker
            }

            return Lottie(
              composition: snapshot.data!,
              width: 300,
              repeat: true,
              fit: BoxFit.contain,
            );
          },
        ),
      ),
    );
  }
}
