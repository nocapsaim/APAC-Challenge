import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:inspector/Gemini_chat_screen.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home_screen.dart';
import 'create_task.dart';
import 'notification_service.dart';
import 'RegisterAsBusinessOwner.dart';
import 'business_owner_home_screen.dart';
import 'home_screen.dart';
import 'Gemini_chat_screen.dart';
import 'GeminiChatForBo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final notificationService = NotificationService();
  await notificationService.initialize(); // Initialize notifications

  // Firebase messaging background handler
  FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received message: ${message.notification?.title}');
    // You can show a local notification here if needed
    notificationService.showLocalNotification(
      message.notification?.title ?? 'No Title',
      message.notification?.body ?? 'No Body',
    );
  });

  runApp(MyApp(notificationService: notificationService));
}

// Background message handler
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  // Handle background notifications (can show a local notification if needed)
}

class MyApp extends StatelessWidget {
  final NotificationService notificationService;

  MyApp({required this.notificationService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Local Freelance Ops',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => OnboardingScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(notificationService: notificationService),  // Pass notificationService
        '/register': (context) => RegisterScreen(),
        '/RegisterAsBusinessOwner': (context) => RegisterAsBusinessOwner(),
        '/createTask': (context) => const CreateTaskScreen(),
        '/chat': (context) => GeminiChatScreen(),
        '/chatforbo': (context) => GeminiChatForBo(),
        '/freelancer-home': (context) => HomeScreen(notificationService: notificationService),
        '/business-home': (context) => BusinessOwnerHomeScreen(notificationService: notificationService),

      },
    );
  }
}
