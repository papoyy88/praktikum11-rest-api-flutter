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
  static const url = 'https://jsonplaceholder.typicode.com/posts';

  List<Post> posts = [];
  bool sedangMemuat = false;
  String? pesanError;
  int? kodeStatusError;
  String kataKunci = '';
  int? filterUserId;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ambilDaftar();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> ambilDaftar({String? customUrl}) async {
    setState(() {
      sedangMemuat = true;
      pesanError = null;
      kodeStatusError = null;
    });

    try {
      final targetUrl = customUrl ?? url;
      final r = await http.get(Uri.parse(targetUrl)).timeout(const Duration(seconds: 10));
      if (r.statusCode != 200) {
        kodeStatusError = r.statusCode;
        throw Exception('HTTP ${r.statusCode} - Resource tidak ditemukan');
      }

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

  void resetFilter() {
    setState(() {
      kataKunci = '';
      filterUserId = null;
      _searchController.clear();
    });
  }

  void tampilkanDetail(Post post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Post #${post.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Chip(label: Text('User ID: ${post.userId}')),
              const SizedBox(height: 8),
              Text(post.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
    final filterAktif = kataKunci.trim().isNotEmpty || filterUserId != null;

    Widget konten;
    if (sedangMemuat) {
      konten = const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Mengambil data dari REST API...'),
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
              if (kodeStatusError != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Status Error: HTTP $kodeStatusError',
                    style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold),
                  ),
                ),
              const Icon(Icons.cloud_off, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(pesanError!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => ambilDaftar(),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    } else if (hasilFilter.isEmpty) {
      konten = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            const Text('Tidak ada data yang cocok dengan kata kunci atau filter.'),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: resetFilter,
              child: const Text('Reset Filter'),
            ),
          ],
        ),
      );
    } else {
      konten = ListView.builder(
        itemCount: hasilFilter.length,
        itemBuilder: (context, index) {
          final post = hasilFilter[index];
          return ListTile(
            leading: CircleAvatar(child: Text('${post.id}')),
            title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('User ID: ${post.userId}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => tampilkanDetail(post),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Praktikum 11: REST API - 240111006'),
        actions: [
          IconButton(
            onPressed: sedangMemuat
                ? null
                : () => ambilDaftar(customUrl: 'https://jsonplaceholder.typicode.com/posts-invalid'),
            icon: const Icon(Icons.bug_report),
            tooltip: 'Simulasi HTTP 404 (T06)',
          ),
          IconButton(
            onPressed: sedangMemuat ? null : () => ambilDaftar(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat Ulang Data',
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
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari judul post...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: kataKunci.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() {
                                kataKunci = '';
                                _searchController.clear();
                              }),
                            )
                          : null,
                      border: const OutlineInputBorder(),
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  filterAktif
                      ? 'Hasil filter: ditemukan ${hasilFilter.length} dari ${posts.length} post'
                      : 'Total data dimuat: ${posts.length} post',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
                if (filterAktif)
                  GestureDetector(
                    onTap: resetFilter,
                    child: const Text(
                      'Reset',
                      style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: konten),
        ],
      ),
    );
  }
}