import 'package:flutter/material.dart';
import 'package:safe_exam/views/screens/teacher_dashboard.dart';

class TeacherAuthView extends StatefulWidget {
  const TeacherAuthView({super.key});

  @override
  State<TeacherAuthView> createState() => _TeacherAuthViewState();
}

class _TeacherAuthViewState extends State<TeacherAuthView> {
  final _adminPasswordController = TextEditingController();
  final String adminSecretKey = "admin2026"; // باسورد المعيد السري الخاص بكِ

  void _verifyAdmin() {
    if (_adminPasswordController.text == adminSecretKey) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TeacherDashboardView()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The instructor password is incorrect!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Instructor Login',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _adminPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Dashboard Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _verifyAdmin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Dashboard Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
