import 'dart:convert';
import 'dart:typed_data';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl; // anciennes images (URL)
  final String imageBase64; // images choisies depuis l'appareil
  final String category;
  final int popularity;
  final double ratingAvg;
  final int ratingCount;
  final int stock;

  /// Octets décodés une seule fois (null si pas d'image locale)
  late final Uint8List? imageBytes = _decode(imageBase64);

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.imageUrl = '',
    this.imageBase64 = '',
    this.popularity = 0,
    this.ratingAvg = 0,
    this.ratingCount = 0,
    this.stock = 0,
  });

  static Uint8List? _decode(String s) {
    if (s.isEmpty) return null;
    try {
      return base64Decode(s);
    } catch (_) {
      return null;
    }
  }

  factory ProductModel.fromMap(String id, Map<String, dynamic> m) {
    return ProductModel(
      id: id,
      name: m['name'] ?? '',
      description: m['description'] ?? '',
      price: (m['price'] ?? 0).toDouble(),
      imageUrl: m['imageUrl'] ?? '',
      imageBase64: m['imageBase64'] ?? '',
      category: m['category'] ?? 'Autres',
      popularity: (m['popularity'] ?? 0).toInt(),
      ratingAvg: (m['ratingAvg'] ?? 0).toDouble(),
      ratingCount: (m['ratingCount'] ?? 0).toInt(),
      stock: (m['stock'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
        'imageBase64': imageBase64,
        'category': category,
        'popularity': popularity,
        'ratingAvg': ratingAvg,
        'ratingCount': ratingCount,
        'stock': stock,
      };
}