import 'package:safe_exam/services/firebase_services.dart';

import '../models/exam_model.dart';

class TeacherController {
  final FirebaseServices _firebaseService = FirebaseServices();
  final List<QuestionModel> questions = [];

  bool addQuestion({
    required String questionText,
    required String optionA,
    required String optionB,
    required String optionC,
    required String optionD,
    required int correctIndex,
  }) {
    if (questionText.trim().isEmpty ||
        optionA.trim().isEmpty ||
        optionB.trim().isEmpty) {
      return false;
    }

    final List<String> options = [];
    if (optionA.trim().isNotEmpty) options.add(optionA.trim());
    if (optionB.trim().isNotEmpty) options.add(optionB.trim());
    if (optionC.trim().isNotEmpty) options.add(optionC.trim());
    if (optionD.trim().isNotEmpty) options.add(optionD.trim());

    // التأكد من أن الفهرس المختار للإجابة الصحيحة موجود فعلياً ضمن الخيارات المضافة
    if (correctIndex >= options.length) {
      return false;
    }

    questions.add(
      QuestionModel(
        questionText: questionText.trim(),
        options: options,
        correctIndex: correctIndex,
      ),
    );
    return true;
  }

  void removeQuestion(int index) {
    if (index >= 0 && index < questions.length) {
      questions.removeAt(index);
    }
  }

  void clearAll() {
    questions.clear();
  }

  // رفع الامتحان لـ Firebase
  Future<bool> publishExam({
    required String title,
    required String password,
  }) async {
    if (title.trim().isEmpty || password.trim().isEmpty || questions.isEmpty) {
      return false;
    }

    bool success = await _firebaseService.publishExamToFirestore(
      examTitle: title.trim(),
      password: password.trim(),
      questions: questions,
    );

    return success;
  }
}
