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
  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    ambilDaftar();
  }

  Future<void> ambilDaftar() async {
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as List<dynamic>;
      final hasil = decoded.map((x) => Post.fromJson(x as Map<String, dynamic>)).toList();
      if (!mounted) return;
      setState(() => posts = hasil);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tahap 4: GET Daftar Post')),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return ListTile(
            leading: CircleAvatar(child: Text('${post.id}')),
            title: Text(post.title),
            subtitle: Text('User ID: ${post.userId} • Post ID: ${post.id}'),
          );
        },
      ),
    );
  }
}