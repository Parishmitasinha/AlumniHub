import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'profilescreen.dart';
import 'postscreen.dart';
import 'manageuserscreen.dart';

class HomePage extends StatelessWidget {
  final String userEmail;
  final bool isSuperAdmin;
  const HomePage({super.key, required this.userEmail, required this.isSuperAdmin});

  Stream<QuerySnapshot> _getPosts() {
    return FirebaseFirestore.instance
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: const Color(0xFF1E4E8A),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF102925),
              ),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Messages'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MessagesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.post_add),
              title: const Text('Posts'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PostScreen()),
                );
              },
            ),

            if (isSuperAdmin)
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Manage Users'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ManageUserScreen()),
                  );
                },
              ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No posts available'));
          }
          final posts = snapshot.data!.docs;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(post['content']),
                subtitle: Text('Posted by: ${post['userName']}'),
              );
            },
          );
        },
      ),
    );
  }
}
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: const Color(0xFFF1F4F6),
      ),
      body: const Center(
        child: Text(
          'Your messages will appear here',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}