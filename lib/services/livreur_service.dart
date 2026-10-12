import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_model.dart';

class LivreurService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Tous les utilisateurs dont le rôle est 'livraison' (mise à jour en direct)
  Stream<List<UserModel>> watchLivreurs() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'livraison')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => UserModel.fromMap(d.id, d.data())).toList());
  }

  /// Crée le compte Auth du livreur + son profil Firestore (role = 'livraison').
  ///
  /// IMPORTANT : createUserWithEmailAndPassword connecte automatiquement le
  /// nouveau compte, ce qui déconnecterait l'admin. On utilise donc une
  /// instance Firebase SECONDAIRE, jetable, pour créer le compte Auth.
  Future<void> createLivreur({
    required String name,
    required String email,
    required String password,
    String address = '',
  }) async {
    final secondary = await Firebase.initializeApp(
      name: 'livreurCreator_${DateTime.now().millisecondsSinceEpoch}',
      options: Firebase.app().options,
    );

    try {
      final auth = FirebaseAuth.instanceFor(app: secondary);
      final cred = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user!.uid;

      final livreur = UserModel(
        uid: uid,
        email: email,
        name: name,
        address: address,
        role: 'livraison',
      );

      try {
        // Écriture avec l'instance principale : c'est l'admin qui écrit
        await _db.collection('users').doc(uid).set(livreur.toMap());
      } catch (e) {
        // Évite un compte Auth orphelin sans profil
        await cred.user!.delete();
        rethrow;
      }

      await auth.signOut();
    } finally {
      await secondary.delete();
    }
  }
}
