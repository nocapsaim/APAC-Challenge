// firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'task.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch tasks for business owner
  Future<List<Task>> getTasks(String businessId) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('tasks')
          .where('createdBy', isEqualTo: businessId)
          .get();

      return snapshot.docs
          .map((doc) => Task.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error fetching tasks: $e");
      return [];
    }
  }

  // Fetch specific task details by task ID
  Future<Task?> getTaskById(String taskId) async {
    try {
      DocumentSnapshot doc = await _db.collection('tasks').doc(taskId).get();

      if (doc.exists) {
        return Task.fromFirestore(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("Error fetching task: $e");
      return null;
    }
  }

  // Create a new task
  Future<void> createTask(String businessId, String title, String description) async {
    try {
      DocumentReference ref = await _db.collection('tasks').add({
        'title': title,
        'description': description,
        'status': 'Pending',  // Default status
        'createdBy': businessId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print("Task created with ID: ${ref.id}");
    } catch (e) {
      print("Error creating task: $e");
    }
  }

  // Update a task's details
  Future<void> updateTask(String taskId, String title, String description, String status) async {
    try {
      await _db.collection('tasks').doc(taskId).update({
        'title': title,
        'description': description,
        'status': status,
      });
      print("Task updated with ID: $taskId");
    } catch (e) {
      print("Error updating task: $e");
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      await _db.collection('tasks').doc(taskId).delete();
      print("Task deleted with ID: $taskId");
    } catch (e) {
      print("Error deleting task: $e");
    }
  }
}
