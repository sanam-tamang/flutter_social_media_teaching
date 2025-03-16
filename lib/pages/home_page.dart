import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:social_media/pages/post_creation_page.dart';
import 'package:social_media/pages/sign_in_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Map<String, dynamic>?> fetchUserDetails() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final response =
          await _client
              .from('users')
              .select('name, email')
              .eq('id', user.id)
              .single();

      return response;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: FutureBuilder<Map<String, dynamic>?>(
            future: fetchUserDetails(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              final userData = snapshot.data;

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.lightBlueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          backgroundImage:
                              userData?['avatar_url'] != null
                                  ? NetworkImage(userData!['avatar_url'])
                                  : null,
                          child:
                              userData?['avatar_url'] == null
                                  ? const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.blue,
                                  )
                                  : null,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          userData?['name'] ?? "Unknown User",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          userData?['email'] ?? "No Email",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text("Logout"),
                    onTap: () async {
                      await _client.auth.signOut();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => SignInPage()),
                        (route) => false,
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text("Social Media"),
        centerTitle: true,
        elevation: 4,
      ),
      body: FutureBuilder(
        future: fetchPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final data = snapshot.data;

          if (data == null || data.isEmpty) {
            return const Center(
              child: Text(
                "No posts available",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final post = data[index];
              final user = post['users'];

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: Colors.grey.withAlpha(130),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.blue.shade100,
                              child: const Icon(
                                Icons.person,
                                size: 28,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                user['name'] ?? "Unknown User",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          post['content'],
                          style: const TextStyle(fontSize: 14, height: 1.4),
                        ),
                        if (post['imageUrl'] != null) ...[
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl:
                                  "https://kkshpkallnttjcdwrpta.supabase.co/storage/v1/object/public/${post['imageUrl']}",
                              placeholder:
                                  (context, url) => Container(
                                    height: 200,
                                    alignment: Alignment.center,
                                    child: const CircularProgressIndicator(),
                                  ),
                              errorWidget:
                                  (context, url, error) => Container(
                                    height: 200,
                                    color: Colors.grey[200],
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.broken_image,
                                      size: 50,
                                    ),
                                  ),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 200,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          post['createdAt'] != null
                              ? "Posted on ${DateTime.parse(post['createdAt']).toLocal().toString().split('.')[0]}"
                              : "",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => PostCreationPage()));

          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<List<dynamic>> fetchPosts() async {
    try {
      final response = await _client
          .from("posts")
          .select('id, content, createdAt, imageUrl, userId, users(name)');

      return response as List<dynamic>;
    } catch (e) {
      print("Error fetching posts: $e");
      return [];
    }
  }
}
