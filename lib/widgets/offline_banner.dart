import 'package:booksbound_app/services/connectivity_service.dart';
import 'package:flutter/material.dart';

class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    ConnectivityService.isOnline().then((online) {
      if (mounted) {
        setState(() => _isOnline = online);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: ConnectivityService.onConnectivityChanged,
      initialData: _isOnline,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;
        if (isOnline) {
          return const SizedBox.shrink();
        }

        return MaterialBanner(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: const Icon(Icons.wifi_off, color: Colors.white),
          backgroundColor: Colors.red.shade700,
          content: const Text(
            "You're offline. Some features may be unavailable.",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          actions: const [
            SizedBox.shrink(),
          ],
        );
      },
    );
  }
}
