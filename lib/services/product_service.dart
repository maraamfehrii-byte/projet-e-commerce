import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  //connexion a firebase
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<ProductModel>> watchProducts() {
    return _db.collection('products').snapshots().map((snap) => snap.docs
        .map((d) => ProductModel.fromMap(d.id, d.data()))
        .toList());
  }

  Future<void> addProduct(ProductModel p) =>
      _db.collection('products').add(p.toMap());

  /// Met à jour les champs modifiables (note et popularité conservées)
  Future<void> updateProduct(ProductModel p) =>
      _db.collection('products').doc(p.id).update({
        'name': p.name,
        'description': p.description,
        'price': p.price,
        'imageUrl': p.imageUrl,
        'imageBase64': p.imageBase64,
        'category': p.category,
        'stock': p.stock,
      });

  Future<void> deleteProduct(String id) =>
      _db.collection('products').doc(id).delete();

  /// Produits de démonstration (réservé à l'admin par les règles Firestore)
  Future<void> seedDemo() async {
    String img(String seed) => 'https://picsum.photos/seed/$seed/500/500';
    final items = <ProductModel>[
      ProductModel(id: '', name: 'Casque Bluetooth', description: 'Casque sans fil avec réduction de bruit et 30 h d\'autonomie.', price: 129.9, imageUrl: img('casque'), category: 'Électronique', popularity: 95, ratingAvg: 4.5, ratingCount: 120, stock: 25),
      ProductModel(id: '', name: 'Montre connectée', description: 'Suivi d\'activité, fréquence cardiaque et notifications.', price: 89.0, imageUrl: img('montre'), category: 'Électronique', popularity: 88, ratingAvg: 4.2, ratingCount: 80, stock: 40),
      ProductModel(id: '', name: 'Enceinte portable', description: 'Son puissant, étanche, idéale pour l\'extérieur.', price: 59.5, imageUrl: img('enceinte'), category: 'Électronique', popularity: 70, ratingAvg: 4.0, ratingCount: 45, stock: 60),
      ProductModel(id: '', name: 'T-shirt en coton', description: 'T-shirt 100 % coton, coupe classique, plusieurs coloris.', price: 19.9, imageUrl: img('tshirt'), category: 'Mode', popularity: 60, ratingAvg: 4.1, ratingCount: 33, stock: 120),
      ProductModel(id: '', name: 'Sneakers urbaines', description: 'Baskets confortables pour un usage quotidien.', price: 74.0, imageUrl: img('sneakers'), category: 'Mode', popularity: 92, ratingAvg: 4.6, ratingCount: 150, stock: 35),
      ProductModel(id: '', name: 'Sac à dos', description: 'Sac 25 L avec compartiment pour ordinateur portable.', price: 45.0, imageUrl: img('sac'), category: 'Mode', popularity: 55, ratingAvg: 4.3, ratingCount: 28, stock: 50),
      ProductModel(id: '', name: 'Lampe de bureau LED', description: 'Lumière réglable, port USB intégré.', price: 32.5, imageUrl: img('lampe'), category: 'Maison', popularity: 48, ratingAvg: 4.4, ratingCount: 21, stock: 70),
      ProductModel(id: '', name: 'Cafetière électrique', description: 'Cafetière 1,2 L avec minuteur programmable.', price: 54.9, imageUrl: img('cafetiere'), category: 'Maison', popularity: 66, ratingAvg: 3.9, ratingCount: 39, stock: 30),
    ];
    final batch = _db.batch();
    for (final p in items) {
      batch.set(_db.collection('products').doc(), p.toMap());
    }
    await batch.commit();
  }
}