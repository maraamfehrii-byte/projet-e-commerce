import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/livreur_controller.dart';
import '../models/user_model.dart';
import 'add_livreur_view.dart';

/// Le controller est créé ici (et pas dans main.dart) pour que le flux
/// Firestore ne démarre que lorsque l'admin ouvre cet écran.
class LivreursView extends StatelessWidget {
  const LivreursView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LivreurController(),
      child: const _LivreursBody(),
    );
  }
}

class _LivreursBody extends StatelessWidget {
  const _LivreursBody();

  @override
  Widget build(BuildContext context) {
    final lc = context.watch<LivreurController>();

    return Scaffold(
      appBar: AppBar(title: Text('Livreurs (${lc.total})')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddLivreurView(controller: lc)),
        ),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Nouveau livreur'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              onChanged: context.read<LivreurController>().setQuery,
              decoration: const InputDecoration(
                hintText: 'Rechercher par nom ou e-mail',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(child: _content(context, lc)),
        ],
      ),
    );
  }

  Widget _content(BuildContext context, LivreurController lc) {
    if (lc.loading) return const Center(child: CircularProgressIndicator());

    if (lc.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(lc.error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(
                  onPressed: lc.retry, child: const Text('Réessayer')),
            ],
          ),
        ),
      );
    }

    final list = lc.livreurs;
    if (list.isEmpty) {
      return Center(
        child: Text(lc.query.isEmpty
            ? 'Aucun livreur pour le moment.'
            : 'Aucun résultat pour « ${lc.query} ».'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 90),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _LivreurTile(user: list[i]),
    );
  }
}

class _LivreurTile extends StatelessWidget {
  final UserModel user;
  const _LivreurTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final bytes = user.photoBytes;
    final initial = user.name.isNotEmpty
        ? user.name[0].toUpperCase()
        : (user.email.isNotEmpty ? user.email[0].toUpperCase() : '?');

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: bytes != null ? MemoryImage(bytes) : null,
          child: bytes == null ? Text(initial) : null,
        ),
        title: Text(user.name.isEmpty ? '(sans nom)' : user.name,
            maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          user.address.isEmpty ? user.email : '${user.email}\n${user.address}',
        ),
        isThreeLine: user.address.isNotEmpty,
      ),
    );
  }
}
