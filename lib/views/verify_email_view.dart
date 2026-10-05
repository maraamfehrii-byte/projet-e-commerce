import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // vérifie automatiquement toutes les 3 secondes
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      context.read<AuthController>().checkVerified();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.mark_email_unread_outlined,
                  size: 90, color: cs.primary),
              const SizedBox(height: 24),
              Text('Vérifiez votre e-mail',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                'Un lien de confirmation a été envoyé à\n'
                '${auth.firebaseUser?.email ?? ''}\n\n'
                'Cliquez dessus pour activer votre compte '
                '(pensez à regarder les spams).',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () =>
                    context.read<AuthController>().checkVerified(),
                child: const Text('J\'ai confirmé mon e-mail'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final err =
                      await context.read<AuthController>().resendVerification();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(err ?? 'E-mail renvoyé.')));
                },
                child: const Text('Renvoyer l\'e-mail'),
              ),
              TextButton(
                onPressed: () => context.read<AuthController>().logout(),
                child: const Text('Se déconnecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}