import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String title;
  final String? description;
  final String? imageUrl;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Post.fromMap(String id, Map<dynamic, dynamic> map) {
    return Post(
      id: id,
      userId: map['userId'] ?? ' ',
      userName: map['userName'] ?? ' ',
      title: map['title'] ?? '',
      description: map['description'],
      imageUrl: map['imageUrl'],
      createdAt:
      DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  List<Post> userPosts = [];
  bool _isLoading = true;
  final DatabaseReference _postsRef = FirebaseDatabase.instance.ref('posts');

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    setState(() => _isLoading = true);
    try {
      _postsRef.onValue.listen((DatabaseEvent event) {
        if (event.snapshot.value != null) {
          final postsData = event.snapshot.value as Map<dynamic, dynamic>;
          List<Post> posts = [];
          postsData.forEach((key, value) {
            posts.add(Post.fromMap(key, value as Map<dynamic, dynamic>));
          });
          posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          setState(() {
            userPosts = posts;
            _isLoading = false;
          });
        } else {
          setState(() {
            userPosts = [];
            _isLoading = false;
          });
        }
      });
    } catch (error) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading posts: $error')),
      );
    }
  }

  Future<void> _deletePost(String postId) async {
    try {
      await _postsRef.child(postId).remove();
      setState(() {
        userPosts.removeWhere((post) => post.id == postId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting post: $error')),
      );
    }
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text("You haven't posted anything yet."),
    );
  }

  Widget _buildPostList() {
    return ListView.builder(
      itemCount: userPosts.length,
      itemBuilder: (context, index) {
        final post = userPosts[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Posted by ${post.userName}',
                  style: TextStyle(fontSize: 13, color: Colors.blueGrey),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.description != null)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(post.description!),
                  ),
                if (post.imageUrl != null)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Image.network(
                      post.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.error, color: Colors.blue),
                    ),
                  ),
                Text(
                  'Posted on ${post.createdAt.toString().substring(0, 16)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deletePost(post.id),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Posts"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : userPosts.isEmpty
          ? _buildEmptyState()
          : _buildPostList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePostScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Create Post',
      ),
    );
  }
}

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _title;
  String? _description;
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final DatabaseReference _postsRef = FirebaseDatabase.instance.ref('posts');

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile =
      await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _imageFile = pickedFile);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<String> _uploadImageToImgBB(File imageFile) async {
    const imgBBUrl = "https://api.imgbb.com/1/upload";
    const apiKey = "051fc3124a49620428487289bd593081";
    final request = http.MultipartRequest("POST", Uri.parse(imgBBUrl))
      ..fields['key'] = apiKey
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseData);
      return jsonResponse['data']['url'];
    } else {
      throw Exception('Failed to upload image to ImgBB');
    }
  }

  Future<void> _submitPost() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() => _isLoading = true);
        _formKey.currentState!.save();

        String? imageUrl;
        if (_imageFile != null) {
          imageUrl = await _uploadImageToImgBB(File(_imageFile!.path));
        }
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception('User not logged in');
        String userName = user.displayName ?? 'Anonymous';

        final newPost = Post(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: user.uid,
          userName: user.displayName ?? 'Anonymous',
          title: _title!,
          description: _description,
          imageUrl: imageUrl,
          createdAt: DateTime.now(),
        );

        await _postsRef.push().set(newPost.toMap());

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully!')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating post: $error')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Post"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Title"),
                onSaved: (value) => _title = value,
                validator: (value) =>
                value == null || value.isEmpty ? "Title is required" : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Description"),
                onSaved: (value) => _description = value,
              ),
              SizedBox(height: 16),
              _imageFile != null
                  ? Image.file(
                File(_imageFile!.path),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              )
                  : ElevatedButton(
                onPressed: _pickImage,
                child: Text("Pick Image"),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitPost,
                child: Text("Post"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}