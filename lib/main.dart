import 'package:flutter/material.dart';
void main() => runApp(const MaterialApp(home: PostPage()));
class PostPage extends StatelessWidget {
  const PostPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Praktikum 11: REST API 240111006_Fayyaz Aqeel Naqib')),
    body: const Center(child: Text('Belum ada data dari server')),
  );
}
