import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:safe_exam/views/screens/exam_screen.dart';
import 'package:safe_exam/views/screens/student_login.dart';
import 'package:safe_exam/views/screens/teacher_auth_view.dart';
import 'package:safe_exam/views/screens/teacher_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة الفايربيز باستخدام إعدادات الويب بتاعتك
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDBebQlc19jAuNT_hjEO2B4V_8vcnlpnAI",
      appId: "1:348562122697:web:5d77c55fb13b646574ea18",
      messagingSenderId: "348562122697",
      projectId: "exam-system-312e6",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quizzz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      // الصفحة الرئيسية (نقدر نخليها شاشة تسجيل الدخول للطالب أو المعيد)
      initialRoute: '/',
      routes: {
        '/': (context) => const StudentLoginView(),
        '/teacher_dashboard': (context) => const TeacherAuthView(),
      },
    );
  }
}
