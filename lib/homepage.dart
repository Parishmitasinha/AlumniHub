import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'profilescreen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Drawer Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(userEmail: '',),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required String userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: const Color(0xFFF4EAEA),
        // Menu icon in AppBar
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
      // Drawer with navigation items
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF0A2647),
              ),
              child: const Text(
                '',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                var userEmail;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage(userEmail: userEmail)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Messages'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MessagesScreen()),
                );
              },
            ),
            // ListTile for My Profile
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.post_add),
              title: const Text('Posts'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PostsScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          'Home Page Content',
          style: TextStyle(fontSize: 20),
        ),
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
        backgroundColor: const Color(0xFF0A2647),
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
class PostsScreen extends StatelessWidget {
  const PostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        backgroundColor: const Color(0xFF0A2647),
      ),
      body: const Center(
        child: Text(
          'User posts will appear here',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
} 