import 'package:flutter/material.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ...List.generate(5, (index) => _PostCard(index: index + 1)),
      ],
    );
  }
}

class _PostCard extends StatelessWidget {
  final int index;

  const _PostCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              child: Text('U$index'),
            ),
            title: Text('Usuario $index'),
            subtitle: const Text('Hace 2 horas'),
          ),
          Container(
            height: 200,
            color: Colors.grey[300],
            child: Center(
              child: Text('Foto de outfit $index'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.favorite_outline),
                      label: const Text('Like'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.comment_outlined),
                      label: const Text('Comentar'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Compartir'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Este outfit combina perfecto para la primavera'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
