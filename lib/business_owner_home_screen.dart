import 'package:flutter/material.dart';
import 'notification_service.dart';
import 'create_task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ApplicantsScreen.dart';

class BusinessOwnerHomeScreen extends StatelessWidget {
  final NotificationService notificationService;

  BusinessOwnerHomeScreen({required this.notificationService});

  final List<String> categoryIcons = [
    'assets/images/gemini-color.png',
    'assets/images/vector.png',
    'assets/images/transformation 1.png',
    'assets/images/pen 1.png',
    'assets/images/layer 1.png',
    'assets/images/group (2).png',
    'assets/images/group (1).png',
    'assets/images/shopping bag.png',
  ];

  @override
  Widget build(BuildContext context) {
    notificationService.showLocalNotification(
        'Welcome!', 'You are now on the business owner home screen.');

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6FF),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A4DFF), Color(0xFF8E60FF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Good Morning',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'Business Owner',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Color(0xFF6A4DFF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                bottom: -10,
                                left: -10,
                                child: Image.asset(
                                  'assets/images/checkmark.png',
                                  width: 80,
                                  height: 80,
                                  color: Colors.white24,
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Icon(Icons.more_horiz,
                                    size: 16, color: Colors.white24),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                        const CreateTaskScreen()),
                                  );
                                },
                                child: StreamBuilder<QuerySnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('tasks')
                                      .where('createdBy',
                                      isEqualTo: FirebaseAuth
                                          .instance.currentUser?.uid)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    int count = 0;
                                    if (snapshot.hasData) {
                                      count = snapshot.data!.docs.where((doc) {
                                        final acceptedBy = doc['acceptedBy'];
                                        // Count only if acceptedBy exists AND is a String (not list or null)
                                        return acceptedBy != null &&
                                            acceptedBy is String &&
                                            acceptedBy.isNotEmpty;
                                      }).length;
                                    }
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Text('$count',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 4),
                                          const Text('Posted Jobs',
                                              style:
                                              TextStyle(color: Colors.white70)),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3EBFFF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                bottom: -10,
                                left: -10,
                                child: Image.asset(
                                  'assets/images/questionmark.png',
                                  width: 80,
                                  height: 80,
                                  color: Colors.white24,
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Icon(Icons.more_horiz,
                                    size: 16, color: Colors.white24),
                              ),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('tasks')
                                    .where('createdBy',
                                    isEqualTo: FirebaseAuth
                                        .instance.currentUser?.uid)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  int acceptedTasksCount = 0;
                                  if (snapshot.hasData) {
                                    acceptedTasksCount = snapshot.data!.docs.where(
                                            (doc) {
                                          final acceptedBy = doc['acceptedBy'];
                                          return acceptedBy is List &&
                                              acceptedBy.isNotEmpty;
                                        }).length;
                                  }

                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ApplicantsScreen(),
                                        ),
                                      );
                                    },
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '$acceptedTasksCount',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            'Applicants',
                                            style: TextStyle(color: Colors.white70),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Categories',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 15,
                      childAspectRatio: 0.99,
                      children: categoryIcons.asMap().entries.map((entry) {
                        int idx = entry.key;
                        String iconPath = entry.value;

                        Widget iconWidget = Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Center(
                            child: Image.asset(
                              iconPath,
                              width: 20,
                              height: 20,
                              fit: BoxFit.contain,
                            ),
                          ),
                        );

                        // Only the first icon (Gemini button) navigates to '/chatforbo'
                        if (idx == 0) {
                          return InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/chatforbo');
                            },
                            child: iconWidget,
                          );
                        } else {
                          return iconWidget;
                        }
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
