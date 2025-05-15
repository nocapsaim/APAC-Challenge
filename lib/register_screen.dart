import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  Future<void> _register(BuildContext context, String role) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'fullName': nameController.text,
        'contact': contactController.text,
        'email': emailController.text,
        'role': role,
      });

      final doc = await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get();
      final retrievedRole = doc.data()?['role'];

      if (retrievedRole == 'Freelancer') {
        Navigator.pushNamed(context, '/freelancer-home');
      } else if (retrievedRole == 'Business Owner') {
        Navigator.pushNamed(context, '/business-home');
      } else {
        Navigator.pushNamed(context, '/home');
      }


    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final purple = Color(0xFF6C47FF);
    final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String role = args['role'];

    return Scaffold(
      backgroundColor: Color(0xFFF6F1FF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Create an Account', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),
            const Text('Please fill registration form below', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 24),
            _buildInputField(nameController, 'Full Name'),
            const SizedBox(height: 16),
            _buildInputField(emailController, 'Email', keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildInputField(contactController, 'Contact Number', keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            _buildInputField(passwordController, 'Password', obscureText: true, isPassword: true),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _register(context, role),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: purple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              ),
              child: const Text('SIGN UP', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text('By tapping “Sign Up” you accept our terms\nand condition', style: TextStyle(fontSize: 12, color: Colors.black54), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 32),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  const Text('Already have an account?', style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/login'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                      decoration: BoxDecoration(color: Color(0xFFE2D4FF), borderRadius: BorderRadius.circular(32)),
                      child: const Text('LOGIN', style: TextStyle(color: Color(0xFF6C47FF), fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text, bool obscureText = false, bool isPassword = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: label,
          border: InputBorder.none,
          suffixIcon: isPassword ? Icon(Icons.visibility, color: Colors.grey.shade400) : null,
        ),
      ),
    );
  }
}
