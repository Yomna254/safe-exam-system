import 'dart:html' as html;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safe_exam/services/firebase_services.dart';
import 'package:safe_exam/views/screens/student_login.dart';

class ExamScreen extends StatefulWidget {
  final String studentId;
  final String examPassword;

  const ExamScreen({
    super.key,
    required this.studentId,
    required this.examPassword,
  });

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  final FirebaseServices _firebaseService = FirebaseServices();

  List<dynamic> _questions = [];
  bool _isLoading = true;
  int _currentQuestionIndex = 0;
  final Map<int, int> _studentAnswers = {}; // تخزين إجابات الطالب
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _fetchExamData();
    _initSecurityListeners(); // تفعيل الحماية ضد الغش
  }

  // 1. جلب الأسئلة من Firebase باستخدام الباسورد
  Future<void> _fetchExamData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.examPassword)
          .get();

      if (doc.exists) {
        setState(() {
          _questions = doc.data()?['questions'] ?? [];
          _isLoading = false;
        });
      } else {
        _showErrorAndExit(
          'The exam does not exist, or the password is incorrect.',
        );
      }
    } catch (e) {
      _showErrorAndExit('An error occurred while loading the exam.');
    }
  }

  // 2. نظام الحماية: مراقبة مغادرة الصفحة أو التاب
  void _initSecurityListeners() {
    // مراقبة تغيير الـ Tab أو تصغير المتصفح
    html.document.addEventListener('visibilitychange', (event) {
      if (html.document.hidden == true && !_isSubmitted) {
        _handleCheatingAttempt(
          "An attempt to leave the exam page (switching tabs) has been detected.",
        );
      }
    });

    // مراقبة فقدان التركيز (فتح برنامج آخر فوق المتصفح)
    html.window.addEventListener('blur', (event) {
      if (!_isSubmitted) {
        _handleCheatingAttempt(
          "The exam has been closed due to a loss of focus or the opening of another window.",
        );
      }
    });

    // منع الكليك يمين
    html.document.onContextMenu.listen((event) => event.preventDefault());
  }

  void _handleCheatingAttempt(String reason) {
    if (_isSubmitted) return;
    _submitExam(isCheating: true, message: reason);
  }

  // 3. تسليم الامتحان (سواء طبيعي أو بسبب الغش)
  Future<void> _submitExam({bool isCheating = false, String? message}) async {
    if (_isSubmitted) return;
    setState(() {
      _isSubmitted = true;
    });

    // حساب الدرجة
    int score = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_studentAnswers[i] == _questions[i]['correctIndex']) {
        score++;
      }
    }

    // إرسال النتيجة لـ Firebase
    await _firebaseService.submitStudentResult(
      examPassword: widget.examPassword,
      studentId: widget.studentId,
      score: isCheating ? 0 : score, // لو غش، الدرجة تصبح صفر
      totalQuestions: _questions.length,
    );

    // عرض النتيجة للطالب
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          isCheating ? 'The exam has been cancelled!' : 'The exam is over.',
        ),
        content: Text(
          isCheating
              ? '$message\n\n Your score has been recorded as (0) due to an attempted act of cheating.'
              : 'You have successfully completed the exam.\n Your grad is: $score out of ${_questions.length}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => StudentLoginView()),
              );
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  void _showErrorAndExit(String errorMsg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('alert'),
        content: Text(errorMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => StudentLoginView()),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_questions.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('There are no questions available in this exam.'),
        ),
      );
    }

    final currentQ = _questions[_currentQuestionIndex];
    List<dynamic> options = currentQ['options'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Section Exam - Student : ${widget.studentId}'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // منع زر الرجوع
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // عداد الأسئلة
            Text(
              'Question ${_currentQuestionIndex + 1} from ${_questions.length}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // نص السؤال
            Text(
              currentQ['questionText'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            // خيارات الإجابة
            ...List.generate(options.length, (index) {
              bool isSelected = _studentAnswers[_currentQuestionIndex] == index;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _studentAnswers[_currentQuestionIndex] = index;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? Colors.blue : Colors.white,
                    foregroundColor: isSelected ? Colors.white : Colors.black87,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    '${String.fromCharCode(65 + index)}. ${options[index]}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            }),
            const Spacer(),
            // أزرار التنقل وتسليم الامتحان
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentQuestionIndex > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentQuestionIndex--;
                      });
                    },
                    child: const Text('previous'),
                  )
                else
                  const SizedBox(),
                if (_currentQuestionIndex < _questions.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentQuestionIndex++;
                      });
                    },
                    child: const Text('next'),
                  )
                else
                  ElevatedButton(
                    onPressed: () => _submitExam(isCheating: false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Send Exam',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
