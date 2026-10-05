import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import 'home_view.dart';
import 'verify_email_view.dart';
import 'admin_home_view.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    // Démarrage ou profil en cours de chargement
    if (auth.initializing ||
        (auth.firebaseUser != null && auth.currentUser == null)) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Visiteur non connecté : il voit le catalogue
    if (auth.firebaseUser == null) return const HomeView();

    final role = auth.currentUser!.role.trim().toLowerCase();

    // Les clients doivent vérifier leur e-mail
    if (role == 'client' && !auth.firebaseUser!.emailVerified) {
      return const VerifyEmailView();
    }

    switch (role) {
      case 'admin':
        return const AdminHomeView();
      case 'livraison':
        return const _DeliveryPlaceholder();
      case 'client':
        return const HomeView();
      default:
        // rôle inconnu : on évite d'afficher l'espace client par erreur
        return Scaffold(
          appBar: AppBar(title: const Text('Rôle inconnu'), actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => context.read<AuthController>().logout(),
            ),
          ]),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Le rôle « ${auth.currentUser!.role} » n\'est pas reconnu.\n'
                'Vérifiez le champ role dans Firestore.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
    }
  }
}

class _DeliveryPlaceholder extends StatelessWidget {
  const _DeliveryPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Espace Livraison'), actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => context.read<AuthController>().logout(),
        ),
      ]),
      body: const Center(child: Text('Espace Livraison')),
    );
  }
}