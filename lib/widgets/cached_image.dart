import 'dart:convert';
import 'dart:typed_data';

import 'package:booksbound_app/widgets/skeleton.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final trimmed = imageUrl.trim();
    if (trimmed.isEmpty) {
      return _buildErrorWidget();
    }

    Widget content;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      content = CachedNetworkImage(
        imageUrl: trimmed,
        width: width,
        height: height,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 150),
        memCacheWidth: width != null && width!.isFinite
            ? (width! * 2.5).toInt()
            : null,
        memCacheHeight: height != null && height!.isFinite
            ? (height! * 2.5).toInt()
            : null,
        placeholder: (context, url) =>
            Skeleton(width: width, height: height, radius: borderRadius),
        errorWidget: (context, url, error) {
          debugPrint('Failed to load image from URL: $url | Error: $error');
          return _buildErrorWidget();
        },
      );
    } else {
      try {
        final cleanBase64 = trimmed.contains(',')
            ? trimmed.split(',').last
            : trimmed;
        final Uint8List bytes = base64Decode(cleanBase64);
        content = Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, _, _) => _buildErrorWidget(),
        );
      } catch (error) {
        debugPrint(
          'Failed to decode image data from URL: $trimmed | Error: $error',
        );
        content = _buildErrorWidget();
      }
    }

    if (borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      );
    }

    return content;
  }

  Widget _buildErrorWidget() {
    Widget errorContent = Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      color: Colors.grey.shade200,
      child: const Icon(Icons.menu_book, color: Colors.grey),
    );

    if (borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: errorContent,
      );
    }
    return errorContent;
  }
}
