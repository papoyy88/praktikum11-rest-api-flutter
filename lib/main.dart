import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: PostPage()));

class Post {
  final int id;
  final int userId;
  final String title;
  final String body;
  const Post({required this.id, required this.userId, required this.title, required this.body});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}

class PostPage extends StatefulWidget {
  const PostPage({super.key});
  @override State<PostPage> createState() => _PostPageState();
}
class _PostPageState extends State<PostPage> {
  String hasil = 'Tekan tombol untuk mengambil satu post';
  Future<void> ambilSatu() async {
    try {
      final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts/2'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');
      final post = Post.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      if (!mounted) return;
      setState(() => hasil = '${post.id} - ${post.title}');
    } catch (e) {
      if (!mounted) return;
      setState(() => hasil = 'Permintaan gagal: $e');
    }
  }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Tahap 3: GET satu data')),
    body: Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(hasil))),
    floatingActionButton: FloatingActionButton(onPressed: ambilSatu, child: const Icon(Icons.download)),
  );
}
