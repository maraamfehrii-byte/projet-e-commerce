import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductImage extends StatelessWidget {
  final ProductModel product;
  final BoxFit fit;
  const ProductImage({super.key, required this.product, this.fit = BoxFit.cover});

  Widget _placeholder(BuildContext context) => Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported_outlined),
      );

  @override
  Widget build(BuildContext context) {
    final bytes = product.imageBytes;
    if (bytes != null) {
      return Image.memory(
        bytes,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
      );
    }
    if (product.imageUrl.isNotEmpty) {
      return Image.network(
        product.imageUrl,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (c, child, p) =>
            p == null ? child : const Center(child: CircularProgressIndicator()),
        errorBuilder: (c, _, __) => _placeholder(c),
      );
    }
    return _placeholder(context);
  }
}