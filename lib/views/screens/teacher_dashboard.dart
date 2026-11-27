import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safe_exam/controllers/teacher_controller.dart';
import 'package:safe_exam/views/widgets/exam_results_view.dart';

import '../widgets/question_form_widget.dart';

class TeacherDashboardView extends StatefulWidget {
  const TeacherDashboardView({super.key});

  @override
  State<TeacherDashboardView> createState() => _TeacherDashboardViewState();
}

class _TeacherDashboardViewState extends State<TeacherDashboardView> {
  final TeacherController _controller = TeacherController();

  final _examTitleController = TextEditingController();
  final _examPasswordController = TextEditingController();

  final _questionController = TextEditingController();
  final _optionAController = TextEditingController();
  final _optionBController = TextEditingController();
  final _optionCController = TextEditingController();
  final _optionDController = TextEditingController();
  int _correctAnswerIndex = 0;

  void _handleAddNewQuestion() {
    bool success = _controller.addQuestion(
      questionText: _questionController.text,
      optionA: _optionAController.text,
      optionB: _optionBController.text,
      optionC: _optionCController.text,
      optionD: _optionDController.text,
      correctIndex: _correctAnswerIndex,
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter the question along with at least two options',
          ),
        ),
      );
      return;
    }

    setState(() {
      _questionController.clear();
      _optionAController.clear();
      _optionBController.clear();
      _optionCController.clear();
      _optionDController.clear();
      _correctAnswerIndex = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('The question has been added successfully!'),
      ),
    );
  }

  Future<void> _handlePublishExam() async {
    // إظهار مؤشر تحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    bool success = await _controller.publishExam(
      title: _examTitleController.text.trim(),
      password: _examPasswordController.text.trim(),
    );

    if (!mounted) return;
    Navigator.pop(context); // إغلاق مؤشر التحميل

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter the exam title and password, and add at least one question.',
          ),
        ),
      );
      return;
    }

    final String password = _examPasswordController.text;

    // مسح البيانات بعد النجاح
    setState(() {
      _examTitleController.clear();
      _examPasswordController.clear();
      _controller.clearAll();
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Published successfully'),
        content: Text('The exam is ready. The section password is: $password'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String generateRandomPassword({int length = 6}) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // استبعاد الحروف المتشابهة زي O و 0 و I و 1
    final random = Random();
    return List.generate(
      length,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  void _showExamPasswordDialogForResults(BuildContext context) {
    final TextEditingController resultPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Show exam results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please enter the password for the exam for which you wish to view the results',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: resultPasswordController,
              decoration: const InputDecoration(
                labelText: 'Exam Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final password = resultPasswordController.text.trim();
              if (password.isNotEmpty) {
                Navigator.pop(context); // إغلاق الـ Dialog
                // الانتقال لصفحة عرض النتائج وتمرير الباسورد
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ExamResultsView(examPassword: password),
                  ),
                );
              }
            },
            child: const Text('Show results'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teaching Assistant Dashboard'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          if (_controller.questions.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _controller.clearAll();
                });
              },
              icon: const Icon(Icons.delete_sweep, color: Colors.white),
              label: const Text(
                'Delete All',
                style: TextStyle(color: Colors.white),
              ),
            ),
          // زارار الانتقال لصفحة النتائج داخل لوحة التحكم
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                // نطلب من المعيد إدخال باسورد الامتحان المراد عرض نتائجه
                _showExamPasswordDialogForResults(context);
              },
              icon: const Icon(Icons.assessment),
              label: const Text('Display student results'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isWideScreen
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 1, child: _buildSettingsSection()),
                  const SizedBox(width: 24),
                  Expanded(flex: 1, child: _buildQuestionsListSection()),
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSettingsSection(),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 500, // تحديد ارتفاع للقائمة في وضع الموبايل
                      child: _buildQuestionsListSection(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Exam Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _examTitleController,
              decoration: const InputDecoration(
                labelText: 'Exam title or section name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _examPasswordController,
                    readOnly: true, // يمنع الكتابة اليدوية لضمان عدم التكرار
                    decoration: const InputDecoration(
                      labelText: 'Random password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.blue),
                  tooltip: 'Generate a new password',
                  onPressed: () {
                    setState(() {
                      _examPasswordController.text = generateRandomPassword();
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.green),
                  tooltip: 'Copy Password',
                  onPressed: () {
                    if (_examPasswordController.text.isNotEmpty) {
                      Clipboard.setData(
                        ClipboardData(text: _examPasswordController.text),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Password copied successfully'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            const Divider(height: 40),
            QuestionFormWidget(
              questionController: _questionController,
              optionAController: _optionAController,
              optionBController: _optionBController,
              optionCController: _optionCController,
              optionDController: _optionDController,
              correctAnswerIndex: _correctAnswerIndex,
              onCorrectAnswerChanged: (val) =>
                  setState(() => _correctAnswerIndex = val ?? 0),
              onAddPressed: _handleAddNewQuestion,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsListSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Added questions (${_controller.questions.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_controller.questions.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear_all, color: Colors.red),
                  onPressed: () => setState(() => _controller.clearAll()),
                  tooltip: 'Delete all questions ',
                ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _controller.questions.isEmpty
                ? const Center(
                    child: Text('You have not added any questions yet.'),
                  )
                : ListView.builder(
                    itemCount: _controller.questions.length,
                    itemBuilder: (context, index) {
                      final q = _controller.questions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(child: Text('${index + 1}')),
                          title: Text(
                            q.questionText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            'the right answer: ${q.options[q.correctIndex]}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                _controller.removeQuestion(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _handlePublishExam,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Publishing the exam',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
