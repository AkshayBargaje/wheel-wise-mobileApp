import 'package:flutter/material.dart';
import 'package:wheelwise/components/screens/helpers/ProgressBar.dart';

class FormSectionHeader extends StatelessWidget {
  final String title;
  final String carName;
  final String subType;
  final int sectionNumber;
  final int totalSection;


  const FormSectionHeader(
      {required this.title,
      required this.carName,
      required this.subType,
      required this.sectionNumber,
      required this.totalSection,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 25,),
              Text(
                carName,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                subType,
                style: TextStyle(fontSize: 16, ),
              ),
              SizedBox(height: 25,),
              ProgressBar(currentStep: sectionNumber+1,totalSteps: totalSection,),
              SizedBox(height: 25,),
                Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ));
  }
}
