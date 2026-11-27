import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/exam_model.dart';

class FirebaseServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. حفظ الامتحان والأسئلة في Firestore
  Future<bool> publishExamToFirestore({
    required String examTitle,
    required String password,
    required List<QuestionModel> questions,
  }) async {
    try {
      List questionsListMap = questions
          .map(
            (q) => {
              'questionText': q.questionText,
              'options': q.options,
              'correctIndex': q.correctIndex,
            },
          )
          .toList();

      await _firestore.collection('exams').doc(password).set({
        'title': examTitle,
        'password': password,
        'questions': questionsListMap,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print('Error publishing exam: $e');
      return false;
    }
  }

  // 2. إرسال نتيجة الطالب وتأمين حالة دخوله
  Future<void> submitStudentResult({
    required String examPassword,
    required String studentId,
    required int score,
    required int totalQuestions,
  }) async {
    await _firestore
        .collection('exams')
        .doc(examPassword)
        .collection('results')
        .doc(studentId)
        .set({
          'studentId': studentId,
          'score': score,
          'total': totalQuestions,
          'submittedAt': FieldValue.serverTimestamp(),
        });
  }
}
