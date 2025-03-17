import 'package:flutter/material.dart';

class ImageContainer extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String placeholderImage;
  final double borderRadius;

  const ImageContainer({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholderImage =
        "https://static.vecteezy.com/system/resources/previews/009/292/244/non_2x/default-avatar-icon-of-social-media-user-vector.jpg",
    this.borderRadius = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(50)),
      child: Image.network(
        imageUrl != null && imageUrl!.isNotEmpty ? imageUrl! : placeholderImage,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Image.network(
            placeholderImage,
            width: width,
            height: height,
            fit: fit,
          );
        },
      ),
    );
  }
}
