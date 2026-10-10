import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Duration fadeInDuration;
  final bool enableCache;
  final int? cacheWidth;
  final int? cacheHeight;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.enableCache = true,
    this.cacheWidth,
    this.cacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    // If image URL is empty, return placeholder
    if (imageUrl.isEmpty) {
      return _buildPlaceholder();
    }

    // For web platform, use basic network image with optimization
    if (kIsWeb) {
      return Image.network(
        _getOptimizedUrl(imageUrl),
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return _buildLoadingWidget();
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    }

    // For mobile platforms, use optimized network image
    return Image.network(
      _getOptimizedUrl(imageUrl),
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth ?? (width?.toInt()),
      cacheHeight: cacheHeight ?? (height?.toInt()),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return AnimatedSwitcher(
            duration: fadeInDuration,
            child: child,
          );
        }
        return _buildLoadingWidget();
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorWidget();
      },
    );
  }

  /// Get optimized URL based on the image service
  String _getOptimizedUrl(String originalUrl) {
    if (originalUrl.isEmpty) return originalUrl;

    // Firebase Storage URLs - add size parameters for thumbnails
    if (originalUrl.contains('firebasestorage.googleapis.com')) {
      return _getFirebaseOptimizedUrl(originalUrl);
    }

    // Unsplash URLs - add quality and size parameters
    if (originalUrl.contains('unsplash.com')) {
      return _getUnsplashOptimizedUrl(originalUrl);
    }

    // Generic images - return as is
    return originalUrl;
  }

  /// Optimize Firebase Storage URLs with thumbnail parameters
  String _getFirebaseOptimizedUrl(String firebaseUrl) {
    if (firebaseUrl.contains('?')) {
      // URL already has parameters, add our optimization
      return '$firebaseUrl&alt=media';
    } else {
      return '$firebaseUrl?alt=media';
    }
  }

  /// Optimize Unsplash URLs with quality and size parameters
  String _getUnsplashOptimizedUrl(String unsplashUrl) {
    final baseUrl = unsplashUrl.split('?')[0];
    final params = <String, String>{
      'q': '80', // Quality 80%
      'w': cacheWidth?.toString() ?? '400',
      'h': cacheHeight?.toString() ?? '300',
      'fit': 'crop',
      'auto': 'format',
    };

    final queryString = params.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    return '$baseUrl?$queryString';
  }

  Widget _buildLoadingWidget() {
    if (placeholder != null) {
      return placeholder!;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.grey[400]!,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (errorWidget != null) {
      return errorWidget!;
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFD8E6FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: (width != null && height != null) ?
                   (width! < height! ? width! * 0.3 : height! * 0.3) : 40,
            color: const Color(0xFF04214E),
          ),
          const SizedBox(height: 4),
          Text(
            'No image',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFD8E6FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: (width != null && height != null) ?
                   (width! < height! ? width! * 0.3 : height! * 0.3) : 40,
            color: const Color(0xFF04214E),
          ),
          const SizedBox(height: 4),
          Text(
            'No image',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

/// Specialized thumbnail widget for list items
class ThumbnailImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;

  const ThumbnailImage({
    super.key,
    required this.imageUrl,
    this.size = 60,
    this.borderRadius,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: OptimizedImage(
        imageUrl: imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: size.toInt() * 2, // 2x for retina displays
        cacheHeight: size.toInt() * 2,
        errorWidget: errorWidget,
        placeholder: Container(
          width: size,
          height: size,
          color: Colors.grey[100],
          child: Icon(
            Icons.image,
            size: size * 0.4,
            color: Colors.grey[400],
          ),
        ),
      ),
    );
  }
}

/// Hero image widget for full-screen views
class HeroImage extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final String? heroTag;

  const HeroImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final widget = OptimizedImage(
      imageUrl: imageUrl,
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
      cacheWidth: 800, // Optimize for typical screen widths
      errorWidget: Container(
        width: double.infinity,
        height: height,
        color: const Color(0xFFD8E6FF),
        child: const Center(
          child: Icon(
            Icons.school,
            size: 80,
            color: Color(0xFF04214E),
          ),
        ),
      ),
    );

    if (heroTag != null) {
      return Hero(
        tag: heroTag!,
        child: widget,
      );
    }

    return widget;
  }
}