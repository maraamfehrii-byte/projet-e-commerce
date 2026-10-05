import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/product_controller.dart';
import '../models/product_model.dart';
import 'login_view.dart';
import 'product_detail_view.dart';
import 'product_image.dart';
import 'profile_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  void _openFilters(BuildContext context) {
    final pc = context.read<ProductController>();
    var range = pc.priceFilter ?? RangeValues(0, pc.maxPrice);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filtrer par prix',
                  style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('${range.start.round()} DT  —  ${range.end.round()} DT'),
              RangeSlider(
                values: range,
                min: 0,
                max: pc.maxPrice,
                divisions: pc.maxPrice.round().clamp(1, 200),
                onChanged: (v) => setState(() => range = v),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48)),
                      onPressed: () {
                        pc.setPriceFilter(null);
                        Navigator.pop(ctx);
                      },
                      child: const Text('Réinitialiser'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        pc.setPriceFilter(range);
                        Navigator.pop(ctx);
                      },
                      child: const Text('Appliquer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final pc = context.watch<ProductController>();
    final products = pc.products;
    final loggedIn = auth.firebaseUser != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Boutique'),
        actions: [
          PopupMenuButton<SortOption>(
            tooltip: 'Trier',
            icon: const Icon(Icons.sort),
            initialValue: pc.sort,
            onSelected: pc.setSort,
            itemBuilder: (_) => const [
              PopupMenuItem(
                  value: SortOption.popularity, child: Text('Popularité')),
              PopupMenuItem(
                  value: SortOption.priceAsc, child: Text('Prix croissant')),
              PopupMenuItem(
                  value: SortOption.priceDesc, child: Text('Prix décroissant')),
            ],
          ),
                    if (loggedIn)
            IconButton(
              tooltip: 'Mon profil',
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProfileView())),
              icon: CircleAvatar(
                radius: 15,
                backgroundImage: auth.currentUser?.photoBytes != null
                    ? MemoryImage(auth.currentUser!.photoBytes!)
                    : null,
                child: auth.currentUser?.photoBytes == null
                    ? const Icon(Icons.person, size: 18)
                    : null,
              ),
            )
          else
            TextButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LoginView())),
              icon: const Icon(Icons.person_outline),
              label: const Text('Connexion'),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Recherche + bouton filtre prix
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: pc.setQuery,
                    decoration: const InputDecoration(
                      hintText: 'Rechercher un produit...',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: 'Filtrer par prix',
                  onPressed: () => _openFilters(context),
                  icon: Icon(pc.hasPriceFilter
                      ? Icons.filter_alt
                      : Icons.filter_alt_outlined),
                ),
              ],
            ),
          ),
          // Catégories
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _chip('Tous', pc.category == null, () => pc.setCategory(null)),
                for (final c in pc.categories)
                  _chip(c, pc.category == c, () => pc.setCategory(c)),
              ],
            ),
          ),
          // Liste
          Expanded(child: _body(context, pc, products)),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onTap(),
        ),
      );

  Widget _body(
      BuildContext context, ProductController pc, List<ProductModel> products) {
    if (pc.loading) return const Center(child: CircularProgressIndicator());
    if (pc.error != null) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(pc.error!, textAlign: TextAlign.center),
      ));
    }
    if (products.isEmpty) {
      return const Center(child: Text('Aucun produit trouvé'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        childAspectRatio: 0.68,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) => _ProductCard(product: products[i]),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: InkWell(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ProductDetailView(product: product))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: ProductImage(product: product),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 16, color: Colors.amber),
                      Text(' ${product.ratingAvg.toStringAsFixed(1)}',
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${product.price.toStringAsFixed(2)} DT',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: cs.primary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}