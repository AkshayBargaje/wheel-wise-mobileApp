import 'package:flutter/material.dart';
import 'package:wheelwise/utils/const.dart';

class ProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ProgressBar({required this.currentStep,required this.totalSteps, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(totalSteps, (index) {
          int step = index + 1;
          return Row(
            children: [
              // Circle for Step
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: step <= currentStep ? AppColors.primaryColor : AppColors.greyColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    "$step",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // Line for Step (skip after the last step)
              if (step < totalSteps)
                Container(
                  height: 2,
                  width: 80,
                  color: step < currentStep ? AppColors.primaryColor : AppColors.greyColor,
                ),
            ],
          );
        }),
      ),
    );
  }
}
