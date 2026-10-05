import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import 'login_view.dart';
import 'register_view.dart';

/// Renvoie true si l'utilisateur est connecté.
/// Sinon affiche une fenêtre l'invitant à se connecter ou à s'inscrire.
bool requireLogin(BuildContext context, {String action = 'continuer'}) {
  final auth = context.read<AuthController>();
  if (auth.firebaseUser != null) return true;

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Connexion requise'),
      content: Text('Connectez-vous ou créez un compte pour $action.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Plus tard'),
        ),
        OutlinedButton(
          onPressed: () {
            Navigator.pop(ctx);
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RegisterView()));
          },
          child: const Text('Créer un compte'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
          onPressed: () {
            Navigator.pop(ctx);
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const LoginView()));
          },
          child: const Text('Se connecter'),
        ),
      ],
    ),
  );
  return false;
}