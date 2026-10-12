import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/livreur_service.dart';

class LivreurController extends ChangeNotifier {
  final LivreurService _service = LivreurService();
  StreamSubscription<List<UserModel>>? _sub;

  List<UserModel> _all = [];
  bool loading = true;
  String? error;
  String query = '';

  LivreurController() {
    _listen();
  }

  void _listen() {
    _sub?.cancel();
    _sub = _service.watchLivreurs().listen(
      (list) {
        _all = list;
        loading = false;
        error = null;
        notifyListeners();
      },
      onError: (e) {
        loading = false;
        error = 'Impossible de charger les livreurs. '
            'Vérifiez les règles Firestore et votre connexion.';
        notifyListeners();
      },
    );
  }

  void retry() {
    loading = true;
    error = null;
    notifyListeners();
    _listen();
  }

  void setQuery(String v) {
    query = v.trim();
    notifyListeners();
  }

  int get total => _all.length;

  /// Renvoie null si OK, sinon le message d'erreur
  Future<String?> addLivreur({
    required String name,
    required String email,
    required String password,
    String address = '',
  }) async {
    try {
      await _service.createLivreur(
        name: name.trim(),
        email: email.trim(),
        password: password,
        address: address.trim(),
      );
      return null;
    } catch (e) {
      return AuthService.errorMessage(e);
    }
  }

  /// Liste filtrée par nom ou e-mail, triée par nom
  List<UserModel> get livreurs {
    final q = query.toLowerCase();
    final list = _all.where((u) {
      if (q.isEmpty) return true;
      return u.name.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q);
    }).toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
