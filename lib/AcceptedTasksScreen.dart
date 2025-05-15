import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AcceptedTasksScreen extends StatelessWidget {
  const AcceptedTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Accepted Jobs'),
        backgroundColor: const Color(0xFF6A4DFF),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .where('acceptedBy', arrayContains: currentUser?.uid ?? 'non-existent-id')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final tasks = snapshot.data?.docs ?? [];

          if (tasks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_turned_in, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No accepted jobs yet'),
                  Text('Accept jobs from Available Jobs', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final data = task.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(data['title'] ?? 'Untitled Task'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['description'] ?? 'No description'),
                      if (data['location'] != null)
                        Text('Location: ${data['location']}'),
                      Chip(
                        label: Text(data['status'] ?? 'Status unknown'),
                        backgroundColor: _getStatusColor(data['status']),
                      ),
                    ],
                  ),
                  trailing: Text(
                    data['createdAt'] != null
                        ? '${(data['createdAt'] as Timestamp).toDate()}'
                        : '',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'assigned': return Colors.blue;
      case 'completed': return Colors.green;
      default: return Colors.grey;
    }
  }
}