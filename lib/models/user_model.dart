import 'dart:convert';
import 'dart:typed_data';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String address;
  final String photoUrl;
  final String photoBase64; // photo choisie depuis l'appareil
  final String role; // 'client' | 'admin' | 'livraison'
  final int orderCount;
  final int loyaltyPoints;

  /// Octets décodés une seule fois (null si pas de photo)
  late final Uint8List? photoBytes = _decode(photoBase64);

  UserModel({
    required this.uid,
    required this.email,
    this.name = '',
    this.address = '',
    this.photoUrl = '',
    this.photoBase64 = '',
    this.role = 'client',
    this.orderCount = 0,
    this.loyaltyPoints =
     0,
  });

  static Uint8List? _decode(String s) {
    if (s.isEmpty) return null;
    try {
      return base64Decode(s);
    } catch (_) {
      return null;
    }
  }

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      photoBase64: map['photoBase64'] ?? '',
      role: map['role'] ?? 'client',
      orderCount: (map['orderCount'] ?? 0).toInt(),
      loyaltyPoints: (map['loyaltyPoints'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'name': name,
        'address': address,
        'photoUrl': photoUrl,
        'photoBase64': photoBase64,
        'role': role,
        'orderCount': orderCount,
        'loyaltyPoints': loyaltyPoints,
      };
}