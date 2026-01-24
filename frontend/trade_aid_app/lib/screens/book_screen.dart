import 'package:flutter/material.dart';

class BookScreen extends StatelessWidget {
  const BookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final books = [
      {'title': 'Flutter for Beginners', 'author': 'A. Dev'},
      {'title': 'Clean Code', 'author': 'R. Martin'},
      {'title': 'Design Patterns', 'author': 'E. Gamma'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Books'), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: books.length,
        itemBuilder: (context, i) {
          final b = books[i];
          return ListTile(
            tileColor: Colors.white,
            title: Text(b['title']!),
            subtitle: Text(b['author']!),
            trailing: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Book details not implemented')));
              },
              child: const Text('View'),
            ),
          );
        },
       separatorBuilder: (_, _) => const SizedBox(height: 12),

      ),
    );
  }
}