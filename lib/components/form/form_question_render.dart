import 'package:flutter/material.dart';

class FormQuestionRenderer extends StatelessWidget {
  final List<Map<String, dynamic>> questions;

  FormQuestionRenderer({required this.questions});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final question = questions[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question["What to Check"],
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              hint: Text("Select Condition"),
              items: question["parameters"].map<DropdownMenuItem<String>>((param) {
                return DropdownMenuItem(
                  value: param["condition"],
                  child: Text(param["condition"]),
                );
              }).toList(),
              onChanged: (value) {
                // Handle dropdown selection
              },
            ),
          ],
        );
      },
    );
  }
}
