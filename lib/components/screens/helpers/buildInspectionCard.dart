import 'package:flutter/material.dart';

import 'CalenderWithDate.dart';
import 'simpleProgressBar.dart';

Widget buildInspectionCard(Map<String, dynamic> inspection, double width) {
  double progress = inspection["status"] == "Pending"
      ? 0.5
      : inspection["status"] == "Submitted"
          ? 0.75 :
          inspection["status"] == "Completed"?1
          : 0.25;
  return Container(
    width: 250,
    margin: EdgeInsets.only(right: 16),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                (inspection['vehicleModel'].toString().length < 10)
                    ? Text(
                        inspection["vehicleModel"]! ?? 'Unknown Car',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      )
                    : Text(
                        inspection['vehicleModel'].toString().substring(0, 10) +
                            '..',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                (inspection['customerName'].toString().length < 10)
                    ? Text(inspection['customerName'].toString(),
                        style: TextStyle(fontSize: 14, color: Colors.white))
                    : Text(
                        inspection['customerName'].toString().substring(0, 10) +
                            '..',
                        style: TextStyle(fontSize: 14, color: Colors.white)),
              ],
            ),
            CalendarWithDate(date: DateTime.now())
          ],
        ),
        Spacer(),
        Text(
          '${inspection['status'] ?? 'N/A'}',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SimpleLineProgressBar(progress: progress)
      ],
    ),
  );
}
