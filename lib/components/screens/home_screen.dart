import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wheelwise/components/auth/login.dart';
import 'package:wheelwise/components/screens/NotificationScreen.dart';
import 'package:wheelwise/components/screens/helpers/CalenderWithDate.dart';
import 'package:wheelwise/components/screens/helpers/ProgressBar.dart';
import 'package:wheelwise/components/screens/helpers/searchBar.dart';
import 'package:wheelwise/helpers/loading_indicator.dart';
import 'package:wheelwise/utils/const.dart';
import 'package:http/http.dart' as http;
import '../../services/jwt_storage.dart';
import 'helpers/buildInspectionCard.dart';
import 'helpers/simpleProgressBar.dart';
import 'inspection_details_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // List<Map<String, String>> inspections = [
  //   {'carName': 'Car A', 'inspectorName': 'Inspector X', 'status': 'Approved'},
  //   {
  //     'carName': 'Car B',
  //     'inspectorName': 'Inspector Y',
  //     'status': 'In Progress'
  //   },
  //   {'carName': 'Car C', 'inspectorName': 'Inspector Z', 'status': 'Declined'},
  // ];

  List<Map<String, dynamic>> inspections = [];

  bool _isLoading = true;

  Map<String, dynamic> statistics = {};
  List<Map<String, String>> tasks = List.generate(
    5,
    (index) => {
      'title': 'Task ${index + 1}',
      'details': 'Details for Task ${index + 1}',
      'icon': 'lib/assets/app-icon/car.png',
    },
  );

  List<Map<String, dynamic>> filteredInspections = [];
  List<dynamic> filteredTasks = [];

  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    // Initialize filtered lists with all items
    // filteredInspections = inspections;
    // filteredTasks = tasks;
    fetchInspections();
  }

  Future<void> fetchInspections() async {
    try {
      String token = (await SecureStorageService.getJwt())!;

      print(token);
      if (token == null) {
        // Handle case where token is not available
        print('No token found, user must login');
        return;
      }

      String url =
          'http://${dotenv.env['HOST']}/api/inspectors/get-details'; // Ensure the URL is correct

      // Sending GET request with authorization header
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": 'Bearer $token',
        },
      );

      print(response);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        statistics = data["statistics"];

        // Assuming the relevant data is in "assignedInspections" field
        List<Map<String, dynamic>> inspections = [];
        for (var inspection in data['assignedInspections']) {
          inspections.add({
            'inspectionId': inspection['inspectionId'],
            'inspectionType': inspection['inspectionType'],
            'subType': inspection['subType'],
            'customerName': inspection['customerName'],
            'status': inspection['status'],
            'vehicleNumber': inspection['vehicle']['number'],
            'vehicleModel': inspection['vehicle']['model'],
            'vehicleMake': inspection['vehicle']['make'],
            'date': inspection['date'],
          });
        }

        //for filter tasks
        final inspectionresp = await http.get(
          Uri.parse('http://${dotenv.env['HOST']}/api/inspections/inspector'),
          headers: {"Authorization": 'Bearer ${token}'},
        );

        if (inspectionresp.statusCode == 200) {
          List<dynamic> tempInspections = json.decode(inspectionresp.body);
          setState(() {
            filteredTasks = tempInspections
                .where((inspection) =>
                    DateTime.now().day ==
                        DateTime.parse(inspection['date']).day &&
                    inspection['status'] == 'Pending')
                .toList();
          });
          print(filteredTasks);
        }
        setState(() {
          // Updating the state with fetched inspections
          this.inspections = inspections;
          this.filteredInspections = inspections;
          _isLoading = false;
        });
      }
      if (response.statusCode == 401) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        throw Exception('Failed to load inspections');
      }
    } catch (error) {
      print('Error fetching inspections: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    var _screenHeight = MediaQuery.of(context).size.height;
    var _screenWidth = MediaQuery.of(context).size.width;

    return _isLoading
        ? LoadingScreen()
        : Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    AppAssets.originalLogo,
                    height: 40,
                    width: 200,
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications, color: Colors.black),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => NotificationScreen()));
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.logout, color: Colors.black),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
              backgroundColor: Colors.white,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'Good Morning,',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Bhavesh!',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor),
                  ),
                  SizedBox(height: 20),
                  // TextField(
                  //   decoration: InputDecoration(
                  //     hintText: 'Search',
                  //     prefixIcon: Icon(Icons.search),
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(8.0),
                  //     ),
                  //   ),
                  //   onChanged: (value) {
                  //     setState(() {
                  //       searchQuery = value.toLowerCase();
                  //       filteredInspections = inspections
                  //           .where((inspection) => inspection['carName']!
                  //               .toLowerCase()
                  //               .contains(searchQuery))
                  //           .toList();
                  //       filteredTasks = tasks
                  //           .where((task) =>
                  //               task['title']!.toLowerCase().contains(searchQuery))
                  //           .toList();
                  //     });
                  //   },
                  // ),
                  CustomSearchBar(),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatBox(
                          'Total Inspections',
                          AppAssets.total_inspection,
                          statistics['totalInspections'].toString(),
                          '+5%',
                          _screenWidth),
                      _buildStatBox(
                          'Approved',
                          AppAssets.completed_inspection,
                          statistics['approvedInspections'].toString(),
                          '+3%',
                          _screenWidth),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatBox(
                          'In Progress',
                          AppAssets.inspection_inProgress,
                          statistics['inProgressInspections'].toString(),
                          '-2%',
                          _screenWidth),
                      _buildStatBox(
                          'Declined',
                          AppAssets.declined_inspection,
                          statistics['declinedInspections'].toString(),
                          '-1%',
                          _screenWidth),
                    ],
                  ),
                  SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Inspection Status',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      PopupMenuButton<String>(
                        color: Colors.black,
                        icon: Icon(
                          Icons.filter_alt,
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'approved',
                            child: Text(
                              'Approved',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'in progress',
                            child: Text(
                              'In Progress',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'declined',
                            child: Text(
                              'Declined',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'pending',
                            child: Text(
                              'Pending',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          setState(() {
                            filteredInspections = inspections
                                .where((inspection) =>
                                    inspection['status']!.toLowerCase() ==
                                    value)
                                .toList();
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(
                      height: 150,
                      width: _screenWidth,
                      child: filteredInspections.length > 0
                          ? ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: filteredInspections.length,
                              itemBuilder: (context, index) {
                                return buildInspectionCard(
                                    filteredInspections[index], 240);
                              },
                            )
                          : Center(child: Text("No Data available"))),
                  SizedBox(height: 40),
                  Text(
                    "Today's Tasks",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  filteredTasks.length > 0
                      ? ListView.builder(
                          itemCount: filteredTasks.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => {
                                // print(filteredTasks[index])
                                // Navigate to the inspection detail page
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => InspectionDetailsPage(
                                              inspection: filteredTasks[index],
                                            )))
                              },
                              child: Container(
                                margin: EdgeInsets.fromLTRB(0, 8, 0, 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey.shade100,
                                ),
                                child: ListTile(
                                  leading: GestureDetector(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Image.asset(filteredTasks[index]
                                              ['icon'] ??
                                          "lib/assets/app-icon/car.png"),
                                    ),
                                  ),
                                  title: Text(
                                    filteredTasks[index]['customer']['name'] ??
                                        'Unknown Task',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          filteredTasks[index]
                                                  ['inspectionType'] ??
                                              'No details available',
                                          style: TextStyle(
                                              color: const Color.fromARGB(
                                                  255, 66, 69, 69))),
                                      Text(
                                          filteredTasks[index]['subType'] ??
                                              'No details available',
                                          style: TextStyle(
                                              color: const Color.fromARGB(
                                                  255, 66, 69, 69))),
                                    ],
                                  ),
                                  trailing: SvgPicture.asset(AppAssets.arrow),
                                ),
                              ),
                            );
                          },
                        )
                      : Center(child: Text("All tasks Done for today"))
                ],
              ),
            ),
          );
  }

  Widget _buildStatBox(String title, String icon, String count, String stats,
      double _screenWidth) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15),
      ),
      width: _screenWidth * 0.42,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
              SvgPicture.asset(icon),
            ],
          ),
          SizedBox(height: 10),
          Text(
            count,
            style: TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(
            stats,
            style: TextStyle(color: Colors.greenAccent, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
