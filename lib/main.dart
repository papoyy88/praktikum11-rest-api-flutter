import 'dart:convert';
import 'package:flutter/material.dart';
void main() => runApp(const MaterialApp(home: PostPage()));
class PostPage extends StatelessWidget {
  const PostPage({super.key});
  @override
  Widget build(BuildContext context) {
    const raw = '{"userId": 1, "id": 101, "title": "Fayyaz Aqeel Naqib", "body": "240111006"}';
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(title: const Text('Tahap 1: JSON Lokal')),
      body: ListTile(title: Text(data['title'] as String), subtitle: Text(data['body'] as String)),
    );
  }
}
