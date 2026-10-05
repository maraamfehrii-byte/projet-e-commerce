import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'login_required.dart';
import 'product_image.dart';

class ProductDetailView extends StatelessWidget {
  final ProductModel product;
  const ProductDetailView({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final inStock = product.stock > 0;

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: ListView(
        children: [
          AspectRatio(
            aspectRatio: 1.2,
            child: ProductImage(product: product),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Chip(label: Text(product.category)),
                const SizedBox(height: 8),
                Text(product.name,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber),
                    Text(
                        ' ${product.ratingAvg.toStringAsFixed(1)} '
                        '(${product.ratingCount} avis)'),
                  ],
                ),
                const SizedBox(height: 12),
                Text('${product.price.toStringAsFixed(2)} DT',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: cs.primary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  inStock ? 'En stock (${product.stock})' : 'Rupture de stock',
                  style: TextStyle(
                      color: inStock ? Colors.green[700] : Colors.red),
                ),
                const SizedBox(height: 16),
                Text('Description',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(product.description),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton.outlined(
                tooltip: 'Ajouter aux favoris',
                onPressed: () {
                  if (!requireLogin(context,
                      action: 'ajouter ce produit à vos favoris')) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Les favoris arrivent à l\'étape 5.')));
                },
                icon: const Icon(Icons.favorite_border),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: !inStock
                      ? null
                      : () {
                          if (!requireLogin(context,
                              action: 'ajouter ce produit au panier')) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Le panier arrive à l\'étape 3.')));
                        },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Ajouter au panier'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}