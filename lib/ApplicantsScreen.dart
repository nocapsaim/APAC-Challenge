import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApplicantsScreen extends StatelessWidget {
  const ApplicantsScreen({super.key});

  Future<Map<String, dynamic>?> _getFreelancerDetails(String uid) async {
    if (uid.isEmpty) return null;
    final doc = await FirebaseFirestore.instance.collection('freelancers').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Applicants'),
        backgroundColor: const Color(0xFF6A4DFF),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .where('createdBy', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Filter tasks where acceptedBy exists and is a non-empty List<String>
          final tasks = snapshot.data!.docs.where((task) {
            final acceptedBy = task['acceptedBy'];
            return acceptedBy != null &&
                acceptedBy is List &&
                acceptedBy.isNotEmpty &&
                acceptedBy.every((element) => element is String && element.isNotEmpty);
          }).toList();

          if (tasks.isEmpty) {
            return const Center(child: Text("No applicants yet."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final taskTitle = task['title'] ?? 'Untitled Job';

              // Safe cast for acceptedBy
              final acceptedByList = List<String>.from(task['acceptedBy'] ?? []);

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  title: Text(taskTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                  children: acceptedByList.map<Widget>((freelancerUid) {
                    return FutureBuilder<Map<String, dynamic>?>(
                      future: _getFreelancerDetails(freelancerUid),
                      builder: (context, freelancerSnapshot) {
                        if (freelancerSnapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!freelancerSnapshot.hasData || freelancerSnapshot.data == null) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Freelancer data not found."),
                          );
                        }

                        final freelancer = freelancerSnapshot.data!;
                        return ListTile(
                          title: Text(freelancer['fullName'] ?? 'No Name'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Email: ${freelancer['email'] ?? 'No Email'}"),
                              Text("Contact: ${freelancer['contact'] ?? 'No Contact'}"),
                            ],
                          ),
                          isThreeLine: true,
                          leading: const Icon(Icons.person),
                        );
                      },
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
