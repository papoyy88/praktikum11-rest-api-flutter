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
  bool sedangMemuat = false;
  String? pesanError;

  @override
  void initState() {
    super.initState();
    ambilDaftar();
  }

  Future<void> ambilDaftar() async {
    setState(() {
      sedangMemuat = true;
      pesanError = null;
    });

    try {
      final r = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/posts'))
          .timeout(const Duration(seconds: 10));
      if (r.statusCode != 200) throw Exception('HTTP ${r.statusCode}');

      final decoded = jsonDecode(r.body) as List<dynamic>;
      final hasil = decoded.map((x) => Post.fromJson(x as Map<String, dynamic>)).toList();

      if (!mounted) return;
      setState(() {
        posts = hasil;
        sedangMemuat = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        pesanError = 'Gagal memuat data: $e';
        sedangMemuat = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget konten;

    if (sedangMemuat) {
      konten = const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Memuat data dari server...'),
          ],
        ),
      );
    } else if (pesanError != null) {
      konten = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(pesanError!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: ambilDaftar,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    } else {
      konten = ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return ListTile(
            leading: CircleAvatar(child: Text('${post.id}')),
            title: Text(post.title),
            subtitle: Text('User ID: ${post.userId} • Post ID: ${post.id}'),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tahap 5: Loading, Error & Retry'),
        actions: [
          IconButton(
            onPressed: sedangMemuat ? null : ambilDaftar,
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat Ulang',
          ),
        ],
      ),
      body: konten,
    );
  }
}