import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailScreen({Key? key, required this.taskId}) : super(key: key);

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late DocumentSnapshot taskSnapshot;

  @override
  void initState() {
    super.initState();
    _fetchTaskDetails();
  }

  // Fetch the task details from Firestore
  Future<void> _fetchTaskDetails() async {
    try {
      DocumentSnapshot task = await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.taskId)
          .get();
      setState(() {
        taskSnapshot = task;
      });
    } catch (e) {
      print('Error fetching task details: $e');
    }
  }

  // Update task status (could be dynamic)
  Future<void> _updateTaskStatus(String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.taskId)
          .update({'status': status});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Task status updated to $status')));
    } catch (e) {
      print('Error updating task status: $e');
    }
  }

  // Assign freelancer to the task
  Future<void> _assignFreelancer(String freelancerId) async {
    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.taskId)
          .update({'freelancer': freelancerId});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Freelancer assigned!')));
    } catch (e) {
      print('Error assigning freelancer: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (taskSnapshot.exists) {
      Map<String, dynamic> taskData = taskSnapshot.data() as Map<String, dynamic>;

      return Scaffold(
        appBar: AppBar(
          title: Text('Task Details'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Task Title: ${taskData['title']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('Description: ${taskData['description']}'),
              SizedBox(height: 10),
              Text('Assigned Freelancer: ${taskData['freelancer'] ?? 'Not Assigned'}'),
              SizedBox(height: 10),
              Text('Status: ${taskData['status']}'),
              SizedBox(height: 20),

              // Update Status Button
              ElevatedButton(
                onPressed: () async {
                  // Example: Update status to 'In Progress'
                  await _updateTaskStatus('In Progress');
                },
                child: Text('Update Status'),
              ),
              SizedBox(height: 20),

              // Assign Freelancer Button
              ElevatedButton(
                onPressed: () async {
                  // Example: Assign freelancer (You should pass the freelancer ID)
                  await _assignFreelancer('freelancer-id-here');
                },
                child: Text('Assign Freelancer'),
              ),
              SizedBox(height: 20),

              // Task Comments Section (Optional)
              Text('Comments:'),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('tasks')
                    .doc(widget.taskId)
                    .collection('comments')
                    .orderBy('timestamp')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Text('No comments yet.');
                  }
                  var comments = snapshot.data!.docs.map((doc) => doc['message']).toList();
                  return ListView.builder(
                    shrinkWrap: true,  // Important to prevent overflow issues
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(comments[index]),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: Text('Task Details')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
  }
}
