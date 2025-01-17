import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wheelwise/components/form/types/Form.dart';
import 'package:http/http.dart' as http;
import 'package:wheelwise/utils/const.dart';

class InspectionDetailsPage extends StatefulWidget {
  final dynamic inspection;

  InspectionDetailsPage({required this.inspection});

  @override
  _InspectionDetailsPageState createState() => _InspectionDetailsPageState();
}

class _InspectionDetailsPageState extends State<InspectionDetailsPage> {
  final TextEditingController _odometerController = TextEditingController();
  bool showOdometer = false;
  String odometerReading = "0";

  Future<void> _getDirections(String address) async {
    final Uri mapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
    try {
      if (await canLaunchUrl(mapsUrl)) {
        await launchUrl(mapsUrl);
      } else {
        throw 'Could not open Google Maps';
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _contactCustomer(String phoneNumber) async {
    final Uri phoneUrl = Uri.parse('tel:+91$phoneNumber');
    if (await canLaunchUrl(phoneUrl)) {
      await launchUrl(phoneUrl);
    } else {
      throw 'Could not open phone dialer';
    }
  }

  Future<void> updateOdometer() async {
    if (_odometerController.text.isEmpty) {
      // Show an alert or return early if the text field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid odometer reading.')),
      );
      return;
    }

    final url = Uri.parse(
        'http://${dotenv.env['HOST']}/api/inspections/update-odometer/${widget.inspection['inspectionId']}');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'odometerReading': int.parse(_odometerController.text),
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        // Update the UI with the new odometer reading
        odometerReading = _odometerController.text;
        widget.inspection['vehicleInfo']['OdometerReading'] = odometerReading;
        showOdometer = true;

        // Clear the text field
        _odometerController.clear();
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Odometer updated successfully!')),
      );
    } else {
      // Handle the error and show a message
      print('Failed to update odometer: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update odometer. Please try again.')),
      );
    }
  }

  void _startInspection(
      BuildContext context, String type, String subType, String formId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomForm(
            formId: formId,
            inspection: widget.inspection,
            subType: subType,
            type: type),
      ),
    );
  }

  @override
  void initState() {
    setState(() {
      odometerReading =
          widget.inspection['vehicleInfo']['OdometerReading'].toString();
    });

    if (odometerReading != '0') {
      showOdometer = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final inspection = widget.inspection;
    final address = inspection['customer']['address'] ?? 'No address available';
    String completeAddress =
        '${address['line1']}, ${address['line2']}, ${address['city']}, ${address['state']}, ${address['postalCode']}, ${address['country']}';
    final customerPhone = inspection['customer']['phone'] ?? 'No phone number';
    final inspectionType = inspection['inspectionType'] ?? 'Unknown Type';
    final inspectionSubType = inspection['subType'] ?? 'Unknown SubType';
    final inspectionId = inspection['inspectionId'] ?? 'Unknown ID';
    final vehicleInfo = inspection['vehicleInfo'] ?? {};

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: Text('Inspection Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 24, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Inspection Info
            Container(
              width: MediaQuery.sizeOf(context).width * 0.8,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.primaryColor),
                  borderRadius: BorderRadius.circular(16)),
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text('Inspection Type: $inspectionType',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor)),
                  Text('Sub-Type: $inspectionSubType',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text('Date: ${inspection['date']}',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text('Time Slot: ${inspection['timeSlot']}',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Customer Info
            Container(
              width: MediaQuery.sizeOf(context).width * 0.8,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.primaryColor),
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text('Customer Details',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor)),
                  Text('Name: ${inspection['customer']['name']}',
                      style: TextStyle(fontSize: 16)),
                  Text('Phone: $customerPhone', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Address Info
            Container(
              width: MediaQuery.sizeOf(context).width * 0.8,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Inspection Address',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(address['line1'], style: TextStyle(fontSize: 16)),
                  Text(address['line2'], style: TextStyle(fontSize: 16)),
                  Text(address['city'], style: TextStyle(fontSize: 16)),
                  Text(address['postalCode'], style: TextStyle(fontSize: 16)),
                  Text(address['country'], style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Vehicle Info
            Container(
              width: MediaQuery.sizeOf(context).width * 0.8,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vehicle Information',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Make: ${vehicleInfo['make']}',
                      style: TextStyle(fontSize: 16)),
                  Text('Model: ${vehicleInfo['model']}',
                      style: TextStyle(fontSize: 16)),
                  Text('Registration: ${vehicleInfo['registrationNumber']}',
                      style: TextStyle(fontSize: 16)),
                  Text('Mileage: ${vehicleInfo['mileage']} km',
                      style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
            SizedBox(height: 16),

            Container(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: UploadTextField(
                odometerController: _odometerController,
                placeholder: showOdometer
                    ? '${odometerReading} km'
                    : 'Enter Odometer Reading',
                onUploadPressed: updateOdometer,
              ),
            ),
            // Buttons
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _getDirections(completeAddress),
                  child: Text('Get Directions',
                      style: TextStyle(
                          fontSize: 16,
                          color: AppColors.black,
                          fontWeight: FontWeight.w600)),
                ),
                ElevatedButton(
                  onPressed: () => _contactCustomer(customerPhone),
                  child: Text('Contact',
                      style: TextStyle(
                          fontSize: 16,
                          color: AppColors.black,
                          fontWeight: FontWeight.w600)),
                ),
                ElevatedButton(
                  onPressed: showOdometer
                      ? () {
                          _startInspection(context, inspectionType,
                              inspectionSubType, inspectionId);
                        }
                      : null,
                  child: Text('Start Inspection',
                      style: TextStyle(
                          fontSize: 16,
                          color: AppColors.black,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UploadTextField extends StatelessWidget {
  final String placeholder;
  final VoidCallback onUploadPressed;
  final TextEditingController odometerController;

  const UploadTextField({
    Key? key,
    required this.placeholder,
    required this.onUploadPressed,
    required this.odometerController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: AppColors.primaryColor),
        borderRadius: BorderRadius.circular(16.0), // Rounded corners
      ),
      child: Row(
        children: [
          // Left side - Text Field with black background
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black, // Black background
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  bottomLeft: Radius.circular(16.0),
                ), // Rounded corners only for the left side
              ),
              child: TextField(
                controller: odometerController,
                decoration: InputDecoration(
                  hintText: placeholder,
                  hintStyle: const TextStyle(color: Colors.white),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 8.0),
                ),
                style: const TextStyle(color: Colors.white), // White text color
              ),
            ),
          ),
          // Right side - Upload button with primary color background
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryColor, // Primary color background
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16.0),
                bottomRight: Radius.circular(16.0),
              ), // Rounded corners only for the right side
            ),
            child: IconButton(
              onPressed: onUploadPressed,
              icon: const Icon(
                Icons.upload,
                color: Colors.white, // White upload icon
              ),
            ),
          ),
        ],
      ),
    );
  }
}
