import 'dart:convert';
import 'package:flutter/material.dart';

/// A reusable avatar widget that supports both network URLs (http/https)
/// and Base64 encoded strings, with graceful error fallback to a person icon.
class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final double radius;
  final Widget? fallbackIcon;

  const UserAvatar({
    super.key,
    required this.photoUrl,
    this.radius = 20,
    this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    final imageProvider = resolveImage(photoUrl);

    return CircleAvatar(
      radius: radius,
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? (fallbackIcon ?? Icon(Icons.person, size: radius))
          : null,
    );
  }

  /// Safely resolves either a NetworkImage, MemoryImage (Base64), or null on failure.
  static ImageProvider? resolveImage(String? url) {
    if (url == null) return null;
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return NetworkImage(trimmed);
    }

    try {
      final cleanBase64 =
          trimmed.contains(',') ? trimmed.split(',').last : trimmed;
      final bytes = base64Decode(cleanBase64);
      return MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }
}
