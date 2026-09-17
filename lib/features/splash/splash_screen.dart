import 'package:booksbound_app/features/auth/login_screen.dart';
import 'package:booksbound_app/features/layout/layout.dart';
import 'package:booksbound_app/services/auth_service.dart';
import 'package:booksbound_app/utils/page_transitions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    final result = await _authService.isLoggedIn();
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    final targetPage =
        (result.isSuccess && (result.data ?? false)) ? const MainLayout() : const LoginScreen();
    Navigator.pushReplacement(
      context,
      FadeRoute(page: targetPage),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _lottie = AssetLottie("assets/lottie/books.json").load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<LottieComposition>(
              future: _lottie,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(height: 240); // no flicker
                }

                return Lottie(
                  composition: snapshot.data!,
                  width: 240,
                  height: 240,
                  repeat: true,
                  fit: BoxFit.contain,
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              "BooksBound",
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontFamily: 'UncialAntiqua',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(
                  begin: const Offset(0.85, 0.85),
                  curve: Curves.easeOutBack,
                  duration: 600.ms,
                ),
            const SizedBox(height: 8),
            Text(
              "Your Portal to Boundless Stories",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                letterSpacing: 0.5,
              ),
            )
                .animate(delay: 300.ms)
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }
}
