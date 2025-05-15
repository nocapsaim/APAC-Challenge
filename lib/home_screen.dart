import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';
import 'available_tasks_screen.dart';
import 'AcceptedTasksScreen.dart';
import 'Gemini_chat_screen.dart';
import 'Gemini_Chat_service.dart';

class HomeScreen extends StatefulWidget {
  final NotificationService notificationService;

  HomeScreen({required this.notificationService});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int availableJobsCount = 0;
  int acceptedJobsCount = 0;

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
  void initState() {
    super.initState();
    widget.notificationService.showLocalNotification('Welcome!', 'You are now on the home screen.');
    fetchJobCounts();
    setupCountListeners();
  }

  void fetchJobCounts() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final availableSnapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('status', isEqualTo: 'Pending')
        .where('acceptedBy', isEqualTo: [])
        .get();

    final acceptedSnapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('acceptedBy', arrayContains: currentUser.uid)
        .get();

    setState(() {
      availableJobsCount = availableSnapshot.docs.length;
      acceptedJobsCount = acceptedSnapshot.docs.length;
    });
  }

  void setupCountListeners() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    FirebaseFirestore.instance
        .collection('tasks')
        .where('status', isEqualTo: 'Pending')
        .where('acceptedBy', isEqualTo: [])
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          availableJobsCount = snapshot.docs.length;
        });
      }
    });

    FirebaseFirestore.instance
        .collection('tasks')
        .where('acceptedBy', arrayContains: currentUser.uid)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          acceptedJobsCount = snapshot.docs.length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF654AEA), Color(0xFF9771FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 10,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Good Morning,',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
                SizedBox(height: 6),
                Text(
                  'Freelancer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildJobCard(
                  title: 'Jobs Available',
                  count: availableJobsCount,
                  color: const Color(0xFF7B61FF),
                  iconPath: 'assets/images/checkmark.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AvailableTasksScreen()),
                    );
                  },
                ),
                const SizedBox(width: 16),
                _buildJobCard(
                  title: 'Accepted Jobs',
                  count: acceptedJobsCount,
                  color: const Color(0xFF47D1FF),
                  iconPath: 'assets/images/questionmark.png',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AcceptedTasksScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Explore Categories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.builder(
                itemCount: categoryIcons.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final iconPath = categoryIcons[index];
                  final iconCard = Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Center(
                      child: Image.asset(
                        iconPath,
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );

                  if (index == 0) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/chat');
                      },
                      child: iconCard,
                    );
                  }

                  return iconCard;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard({
    required String title,
    required int count,
    required Color color,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 130,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: -10,
                left: -10,
                child: Image.asset(
                  iconPath,
                  width: 80,
                  height: 80,
                  color: Colors.white24,
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: const Icon(Icons.more_vert, color: Colors.white30),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
