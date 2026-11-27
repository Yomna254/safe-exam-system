import 'package:flutter/material.dart';

class QuestionFormWidget extends StatelessWidget {
  final TextEditingController questionController;
  final TextEditingController optionAController;
  final TextEditingController optionBController;
  final TextEditingController optionCController;
  final TextEditingController optionDController;
  final int correctAnswerIndex;
  final ValueChanged<int?> onCorrectAnswerChanged;
  final VoidCallback onAddPressed;

  const QuestionFormWidget({
    super.key,
    required this.questionController,
    required this.optionAController,
    required this.optionBController,
    required this.optionCController,
    required this.optionDController,
    required this.correctAnswerIndex,
    required this.onCorrectAnswerChanged,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Add new question',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: questionController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'question text',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: optionAController,
            decoration: const InputDecoration(
              labelText: 'First choice (A)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: optionBController,
            decoration: const InputDecoration(
              labelText: 'Second choice (B)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: optionCController,
            decoration: const InputDecoration(
              labelText: 'Third choice (C - optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: optionDController,
            decoration: const InputDecoration(
              labelText: 'Fourth choice (D - optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: correctAnswerIndex,
            decoration: const InputDecoration(
              labelText: 'Select the correct answer.',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 0, child: Text('First choice (A)')),
              DropdownMenuItem(value: 1, child: Text('Second choice (B)')),
              DropdownMenuItem(value: 2, child: Text('Third choice (C)')),
              DropdownMenuItem(value: 3, child: Text('Fourth choice (D)')),
            ],
            onChanged: onCorrectAnswerChanged,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onAddPressed,
            icon: const Icon(Icons.add),
            label: const Text('Add the question to the list'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
