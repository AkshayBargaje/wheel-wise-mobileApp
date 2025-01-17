import 'package:flutter/material.dart';
import 'package:wheelwise/utils/const.dart';

class SimpleLineProgressBar extends StatelessWidget {
  final double progress; // Must be one of: 0.25, 0.5, 0.75, or 1.0

  const SimpleLineProgressBar({required this.progress, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(5),
      ),
      child: FractionallySizedBox(
        widthFactor: progress,
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: progress == 1.0 ? Colors.green : AppColors.primaryColor,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }
}
