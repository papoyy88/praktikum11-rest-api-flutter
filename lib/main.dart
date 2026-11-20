import 'dart:convert';
import 'package:flutter/material.dart';

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

void main() => runApp(const MaterialApp(home: PostPage()));
class PostPage extends StatelessWidget {
  const PostPage({super.key});
  @override
  Widget build(BuildContext context) {
    const raw = '{"userId": 1, "id": 101, "title": "Model Post", "body": "Parsing tervalidasi tipenya"}';
    final post = Post.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    return Scaffold(
      appBar: AppBar(title: const Text('Tahap 2: Model Data')),
      body: ListTile(
        leading: CircleAvatar(child: Text('${post.userId}')),
        title: Text(post.title),
        subtitle: Text('User ID: ${post.userId} | ID ${post.id}: ${post.body}'),
      ),

    );
  }
}
