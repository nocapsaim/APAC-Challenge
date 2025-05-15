class Task {
  String id;
  String title;
  String description;
  String status;
  String createdBy;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdBy,
  });

  factory Task.fromFirestore(Map<String, dynamic> firestoreDoc) {
    return Task(
      id: firestoreDoc['id'],
      title: firestoreDoc['title'],
      description: firestoreDoc['description'],
      status: firestoreDoc['status'],
      createdBy: firestoreDoc['createdBy'],
    );
  }
}
