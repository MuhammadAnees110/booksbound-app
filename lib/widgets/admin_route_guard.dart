import 'package:booksbound_app/providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminRouteGuard extends StatefulWidget {
  final Widget child;

  const AdminRouteGuard({super.key, required this.child});

  @override
  State<AdminRouteGuard> createState() => _AdminRouteGuardState();
}

class _AdminRouteGuardState extends State<AdminRouteGuard> {
  late final Future<bool> _authorization;
  bool _redirectStarted = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _authorization = Future.value(false);
      return;
    }

    final profileProvider = context.read<ProfileProvider>();
    _authorization = profileProvider
        .loadRole(user.uid)
        .then((_) => profileProvider.isAdmin);
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      if (!_redirectStarted) {
        _redirectStarted = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(
              context,
              rootNavigator: true,
            ).pushNamedAndRemoveUntil('/login', (_) => false);
          }
        });
      }
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return FutureBuilder<bool>(
      future: _authorization,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data != true) {
          return const Scaffold(body: Center(child: Text('Access Denied')));
        }
        return widget.child;
      },
    );
  }
}
