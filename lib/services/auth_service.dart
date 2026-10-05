import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Crée le compte Auth + le profil Firestore, et renvoie le profil.
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = UserModel(
      uid: cred.user!.uid,
      email: email,
      name: name,
      role: 'client', // toujours client à l'inscription
    );
    //Enregistrer dans Firestore
    await _db.collection('users').doc(user.uid).set(user.toMap());
    //Vérification de l'email
    await cred.user!.sendEmailVerification();
    return user;
  }

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();
// mdp oublier
  Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email);
  //cherche le profil d'un utilisateur dans Firestor
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(uid, doc.data()!);
  }
    /// Met à jour nom, adresse et (optionnellement) la photo, puis renvoie le profil à jour
  Future<UserModel?> updateProfile({
    required String uid,
    required String name,
    required String address,
    String? photoBase64,
  }) async {
    final data = <String, dynamic>{'name': name, 'address': address};
    if (photoBase64 != null) data['photoBase64'] = photoBase64;
    await _db.collection('users').doc(uid).update(data);
    return getUser(uid);
  }

  /// Convertit les erreurs Firebase en messages français
  static String errorMessage(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return "Adresse e-mail invalide.";
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return "Identifiants incorrects.";
        case 'email-already-in-use':
          return "Cet e-mail est déjà utilisé.";
        case 'weak-password':
          return "Mot de passe trop faible (6 caractères minimum).";
        case 'network-request-failed':
          return "Problème de connexion réseau.";
        case 'too-many-requests':
          return "Trop de tentatives. Réessayez plus tard.";
        default:
          return "Erreur d'authentification (${e.code}).";
      }
    }
    if (e is FirebaseException && e.code == 'permission-denied') {
      return "Accès refusé : vérifiez les règles Firestore.";
    }
    return "Une erreur est survenue.";
  }
    Future<void> sendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  /// Recharge l'utilisateur et renvoie true si l'e-mail est vérifié
  Future<bool> reloadAndCheckVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }
}