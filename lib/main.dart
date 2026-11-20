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
  String kataKunci = '';
  int? filterUserId;

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

  List<Post> get postTerfilter {
    final q = kataKunci.trim().toLowerCase();
    return posts.where((p) {
      final cocokJudul = q.isEmpty || p.title.toLowerCase().contains(q);
      final cocokUser = filterUserId == null || p.userId == filterUserId;
      return cocokJudul && cocokUser;
    }).toList();
  }

  void tampilkanDetail(Post post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Post #${post.id} (User ${post.userId})'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(post.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(post.body),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final daftarUser = posts.map((p) => p.userId).toSet().toList()..sort();
    final hasilFilter = postTerfilter;

    Widget konten;
    if (sedangMemuat) {
      konten = const Center(child: CircularProgressIndicator());
    } else if (pesanError != null) {
      konten = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(pesanError!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: ambilDaftar, child: const Text('Coba Lagi')),
          ],
        ),
      );
    } else if (hasilFilter.isEmpty) {
      konten = const Center(child: Text('Tidak ada post yang cocok dengan pencarian/filter.'));
    } else {
      konten = ListView.builder(
        itemCount: hasilFilter.length,
        itemBuilder: (context, index) {
          final post = hasilFilter[index];
          return ListTile(
            leading: CircleAvatar(child: Text('${post.id}')),
            title: Text(post.title),
            subtitle: Text('User ID: ${post.userId}'),
            onTap: () => tampilkanDetail(post),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tahap 6: Pencarian, Filter & Detail'),
        actions: [
          IconButton(
            onPressed: sedangMemuat ? null : ambilDaftar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Cari judul post...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (val) => setState(() => kataKunci = val),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<int?>(
                  value: filterUserId,
                  hint: const Text('Semua User'),
                  items: [
                    const DropdownMenuItem<int?>(value: null, child: Text('Semua User')),
                    ...daftarUser.map(
                      (uid) => DropdownMenuItem<int?>(value: uid, child: Text('User $uid')),
                    ),
                  ],
                  onChanged: (val) => setState(() => filterUserId = val),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Menampilkan ${hasilFilter.length} dari ${posts.length} post',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(child: konten),
        ],
      ),
    );
  }
}