import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:wheelwise/helpers/loading_indicator.dart';
import '../../services/jwt_storage.dart';
import '../../utils/const.dart';
import '../../utils/date_time.dart';
import 'inspection_details_page.dart';

class TodaySInspection extends StatefulWidget {
  @override
  State<TodaySInspection> createState() => _TodaySInspectionState();
}

class _TodaySInspectionState extends State<TodaySInspection> {
  List<dynamic> assignedInspections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchInspections();
  }

  Future<void> fetchInspections() async {
    // Check if the session is active. If not, navigate to login.
    await SecureStorageService.checkSessionAndNavigate(context);

    try {
      String token = (await SecureStorageService.getJwt())!;
      if (token == null) {
        // If there's no token, navigate to login (this should be handled by the checkSessionAndNavigate method)
        return;
      }

      final response = await http.get(
        Uri.parse('http://${dotenv.env['HOST']}/api/inspections/inspector'),
        headers: {"Authorization": 'Bearer ${token}'},
      );
      print(response.body);

      if (response.statusCode == 200) {
        List<dynamic> inspections = json.decode(response.body);

        // Separate inspections into assigned and completed
        setState(() {
          assignedInspections = inspections.where((inspection) =>
                DateTime.now().day == DateTime.parse(inspection['date']).day && inspection['status'] == 'Pending'
                
                ).toList();
                _isLoading = false;
        });
      } else {
        throw Exception('Failed to load inspections');
      }
    } catch (e) {
      print('Error fetching inspections: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return 
    _isLoading?
    LoadingScreen()
    :
    Container(
      padding: EdgeInsets.all(16),
      child: assignedInspections.length > 0
          ? ListView.builder(
              itemCount: assignedInspections.length,
              itemBuilder: (context, index) {
                return AssignedTaskTile(
                  inspection: assignedInspections[index],
                );
              },
            )
          : Center(child: Text("No Inspection Found")),
    );
  }
}

class AssignedTaskTile extends StatelessWidget {
  final dynamic inspection;

  AssignedTaskTile({required this.inspection});

  @override
  Widget build(BuildContext context) {
    String month = formatMonth(inspection["date"]);
    String day = formatDay(inspection["date"]);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // Changes position of shadow
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Date and Inspection Details
          Row(
            children: [
              // Date Container
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Column(
                  children: [
                    Text(
                      day,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      month, // Placeholder for month
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              // Inspection Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      ((inspection["inspectionType"]+ "${"  "}"+inspection["subType"]).toString().length < 20)
                    ? Text(
                        inspection["inspectionType"]+ "${"  "}"+inspection["subType"]! ?? 'Unknown Car',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black),
                      )
                    : Text(
                        (inspection["inspectionType"]+ "${"  "}"+inspection["subType"]).toString().substring(0, 20) +
                            '..',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black)),
                      ((inspection["vehicleInfo"]["model"] + "${"  "}"+inspection["vehicleInfo"]["make"]).toString().length < 20)
                    ? Text(
                        inspection["vehicleInfo"]["model"] + "${"  "}"+inspection["vehicleInfo"]["make"]! ?? 'Unknown Car',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black),
                      )
                    : Text(
                        (inspection["vehicleInfo"]["model"] + "${"  "}"+inspection["vehicleInfo"]["make"]).toString().substring(0, 20) +
                            '..',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black)),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset("lib/assets/app-icon/clock.svg"),
                        SizedBox(width: 5,),
                        Text(
                          inspection["timeSlot"],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Divider(),
          // Footer Row: View Details Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Inspection type (additional data)
              Text(
               inspection["customer"]["name"], // You can add a new field for this if required
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold
                ),
              ),
              // View Details Button
              GestureDetector(
                onTap: () {
                  // Add your desired onTap functionality here
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (_) => Points128(formId: inspection["inspectionId"])));
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => InspectionDetailsPage(inspection: inspection,)));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xff2115FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Text(
                    "View Details",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
