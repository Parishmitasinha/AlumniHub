import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageUserScreen extends StatefulWidget {
  const ManageUserScreen({super.key});

  @override
  _ManageUserScreenState createState() => _ManageUserScreenState();
}

class _ManageUserScreenState extends State<ManageUserScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late User _user;
  bool _isLoading = true;

  List<Map<String, dynamic>> _userList = [];

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;

    if (_user.email?.toLowerCase() == 'admin@example.com') {
      _fetchUsers();
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _fetchUsers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      setState(() {
        _userList = querySnapshot.docs
            .map((doc) => {
          'name': doc['name'],
          'email': doc['email'],
          'studentId': doc['studentId'],
          'department': doc['department'],
        })
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error fetching users: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userList.isEmpty
          ? const Center(child: Text('No users registered yet'))
          : ListView.builder(
        itemCount: _userList.length,
        itemBuilder: (context, index) {
          var user = _userList[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(user['name']),
              subtitle: Text('Email: ${user['email']}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  _deleteUser(user['email']);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteUser(String email) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        String userId = querySnapshot.docs.first.id;
        await _firestore.collection('users').doc(userId).delete();

        var userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
            email: email, password: 'dummyPassword');
        await userCredential.user?.delete();

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$email has been deleted.'),
          backgroundColor: Colors.green,
        ));
        _fetchUsers();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error deleting user: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }
}
