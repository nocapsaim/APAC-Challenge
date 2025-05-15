import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  String title = '';
  String location = '';
  String description = '';
  double? budget;
  DateTime? deadline;

  String? uid;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        uid = user.uid;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _submitTask() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    if (_formKey.currentState!.validate() && deadline != null) {
      _formKey.currentState!.save();

      try {
        await FirebaseFirestore.instance.collection('tasks').add({
          'title': title,
          'location': location,
          'description': description,
          'budget': budget,
          'status': 'Pending',
          'deadline': deadline,
          'createdAt': Timestamp.now(),
          'createdBy': uid,
          'acceptedBy': [],
        });

        _formKey.currentState!.reset();
        setState(() {
          deadline = null;
          budget = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task created successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create task: $e')),
        );
      }
    }
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    setState(() {
      deadline = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _deleteTask(String docId) async {
    await FirebaseFirestore.instance.collection('tasks').doc(docId).delete();
  }

  void _editTask(String docId, Map<String, dynamic> currentData) {
    title = currentData['title'];
    location = currentData['location'];
    description = currentData['description'];
    deadline = (currentData['deadline'] as Timestamp).toDate();
    budget = (currentData['budget'] != null) ? (currentData['budget'] as num).toDouble() : null;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Task'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextFormField('Title', initialValue: title, onSaved: (v) => title = v ?? ''),
                const SizedBox(height: 12),
                _buildTextFormField('Location', initialValue: location, onSaved: (v) => location = v ?? ''),
                const SizedBox(height: 12),
                _buildTextFormField('Description', initialValue: description, maxLines: 3, onSaved: (v) => description = v ?? ''),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: budget?.toString(),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Budget (USD)',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (val) => budget = val != null ? double.tryParse(val) : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              _formKey.currentState!.save();
              await FirebaseFirestore.instance.collection('tasks').doc(docId).update({
                'title': title,
                'location': location,
                'description': description,
                'budget': budget,
                'deadline': deadline,
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField(String label,
      {String? initialValue, int maxLines = 1, required FormFieldSetter<String> onSaved}) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      validator: (value) => (value == null || value.isEmpty) ? 'Please enter $label' : null,
      onSaved: onSaved,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Create New Task'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextFormField(
                    'Task Title',
                    onSaved: (val) => title = val!,
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    'Location',
                    onSaved: (val) => location = val!,
                  ),
                  const SizedBox(height: 20),
                  _buildTextFormField(
                    'Description',
                    maxLines: 5,
                    onSaved: (val) => description = val!,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Budget (USD)',
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Please enter Budget';
                      final numValue = double.tryParse(val);
                      if (numValue == null || numValue <= 0) {
                        return 'Please enter a valid positive number';
                      }
                      return null;
                    },
                    onSaved: (val) => budget = val != null ? double.parse(val) : null,
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Deadline', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      deadline != null
                          ? '${deadline!.day}/${deadline!.month}/${deadline!.year} ${deadline!.hour.toString().padLeft(2, '0')}:${deadline!.minute.toString().padLeft(2, '0')}'
                          : 'Select deadline',
                      style: TextStyle(
                        color: deadline != null ? Colors.black87 : Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    trailing: const Icon(Icons.calendar_today_rounded, color: Colors.black54),
                    onTap: _pickDeadline,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 6,
                        shadowColor: Colors.deepPurpleAccent.withOpacity(0.4),
                      ),
                      onPressed: _submitTask,
                      child: const Text(
                        'Submit Task',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Text('My Tasks',
                style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent,
                )),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tasks')
                  .where('createdBy', isEqualTo: FirebaseAuth.instance.currentUser?.uid ?? '')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('No tasks created yet.'),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final deadlineText = data['deadline'] != null
                        ? (data['deadline'] as Timestamp).toDate()
                        : null;

                    final deadlineStr = deadlineText != null
                        ? '${deadlineText.day}/${deadlineText.month}/${deadlineText.year} ${deadlineText.hour.toString().padLeft(2, '0')}:${deadlineText.minute.toString().padLeft(2, '0')}'
                        : 'No deadline';

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      shadowColor: Colors.deepPurpleAccent.withOpacity(0.15),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        title: Text(
                          data['title'] ?? 'No title',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Location: ${data['location'] ?? 'No location'}'),
                              const SizedBox(height: 4),
                              Text('Description: ${data['description'] ?? 'No description'}'),
                              const SizedBox(height: 4),
                              Text('Budget: \$${data['budget']?.toStringAsFixed(2) ?? 'N/A'}'),
                              const SizedBox(height: 4),
                              Text('Deadline: $deadlineStr'),
                              const SizedBox(height: 4),
                              Text('Status: ${data['status'] ?? 'Unknown'}'),
                            ],
                          ),
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') _editTask(doc.id, data);
                            if (value == 'delete') _deleteTask(doc.id);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
