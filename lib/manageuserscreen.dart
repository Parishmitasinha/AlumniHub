import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class ManageUserScreen extends StatefulWidget {
  const ManageUserScreen({Key? key}) : super(key: key);

  @override
  _ManageUserScreenState createState() => _ManageUserScreenState();
}

class _ManageUserScreenState extends State<ManageUserScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _getPendingUsers() async {
    QuerySnapshot snapshot = await _firestore
        .collection('pending_approval')
        .where('status', isEqualTo: 'pending')
        .get();

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<void> _sendEmail(String userEmail, String userName, String status) async {
    final Email email = Email(
      body: 'Dear $userName,\n\nYour account status has been updated to: $status.',
      subject: 'Account Status Update',
      recipients: [userEmail],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email sent to $userName with status $status')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending email: $e')),
      );
    }
  }

  Future<void> _approveUser(String userId, String userEmail, String userName) async {
    try {
      await _firestore.collection('pending_approval').doc(userId).update({
        'status': 'approved',
      });

      await _sendEmail(userEmail, userName, 'approved');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User approved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _rejectUser(String userId, String userEmail, String userName) async {
    try {
      await _firestore.collection('pending_approval').doc(userId).update({
        'status': 'rejected',
      });

      await _sendEmail(userEmail, userName, 'rejected');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User rejected successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage User Requests'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getPendingUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.data?.isEmpty ?? true) {
            return const Center(child: Text('No users to approve.'));
          }

          final users = snapshot.data ?? [];

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              String userId = user['uid'] ?? '';
              String name = user['name'] ?? 'Unknown';
              String email = user['email'] ?? 'No email provided';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: ListTile(
                  title: Text(name),
                  subtitle: Text(email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _approveUser(userId, email, name),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _rejectUser(userId, email, name),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}