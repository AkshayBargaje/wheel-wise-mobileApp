import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wheelwise/utils/const.dart'; // For formatting dates

class CalendarWithDate extends StatelessWidget {
  final DateTime date;

  const CalendarWithDate({required this.date, Key? key}) : super(key: key);

  String _formatDate(DateTime date) {
    // Convert date to '21DEC24' format
    return DateFormat('ddMMMyy').format(date).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Icon(Icons.calendar_today, size: 20, color: Colors.white),
        SizedBox(height: 4),
        Text(
          _formatDate(date)+"'",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor
          ),
        ),
      ],
    );
  }
}
