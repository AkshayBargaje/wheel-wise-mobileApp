import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';

// class InspectionPage extends StatefulWidget {
//   @override
//   _InspectionPageState createState() => _InspectionPageState();
// }

// class _InspectionPageState extends State<InspectionPage> {
//   // List to hold inspections data

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 3, // Three tabs
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text('Inspections'),
//           bottom: TabBar(
//             tabs: [
//               Tab(text: 'Assigned'),
//               Tab(text: 'Completed'),
//               Tab(text: 'History'), // Optional tab for other types of inspections
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             // Tab 1: Assigned Inspections
//             InspectionList(inspections: assignedInspections),

//             // Tab 2: Completed Inspections
//             InspectionList(inspections: completedInspections),

//             // Tab 3: History or any other content (Optional)
//             Center(child: Text('History Tab')),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class InspectionList extends StatelessWidget {
//   final List<dynamic> inspections;

//   const InspectionList({Key? key, required this.inspections}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     if (inspections.isEmpty) {
//       return Center(child: Text('No inspections available.'));
//     }

//     return ListView.builder(
//       itemCount: inspections.length,
//       itemBuilder: (context, index) {
//         final inspection = inspections[index];
//         return InspectionCard(inspection: inspection);
//       },
//     );
//   }
// }

// class InspectionCard extends StatelessWidget {
//   final dynamic inspection;

//   const InspectionCard({Key? key, required this.inspection}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final vehicle = inspection['vehicleInfo'];
//     final customer = inspection['customer'];

//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           Card(
//             margin: EdgeInsets.all(8.0),
//             elevation: 4.0,
//             child: ListTile(
//               contentPadding: EdgeInsets.all(12.0),
//               title: Text('${vehicle['make']} ${vehicle['model']} (${vehicle['year']})'),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Inspection Type: ${inspection['inspectionType']}'),
//                   Text('Date: ${inspection['date']}'),
//                   Text('Time Slot: ${inspection['timeSlot']}'),
//                   Text('Customer: ${customer['name']}'),
//                   Text('Status: ${inspection['status']}'),
//                 ],
//               ),
//               trailing: Icon(Icons.arrow_forward),
//               onTap: () {
//                 // Navigate to a detail page or any action for the inspection
//                 // Navigator.push(context, MaterialPageRoute(builder: (_) => InspectionDetailPage(inspection: inspection)));
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wheelwise/components/screens/helpers/buildInspectionCard.dart';
import 'package:wheelwise/components/screens/helpers/searchBar.dart';
import 'package:wheelwise/helpers/loading_indicator.dart';
import 'package:wheelwise/utils/const.dart';
import 'package:wheelwise/utils/date_time.dart';

import '../../services/jwt_storage.dart';
import 'helpers/CalenderWithDate.dart';
import 'helpers/simpleProgressBar.dart';
import 'inspection_details_page.dart';

class InspectionPage extends StatefulWidget {
  @override
  _InspectionPageState createState() => _InspectionPageState();
}

class _InspectionPageState extends State<InspectionPage> {
  final List<String> searchBarTexts = [
    "Search for Assigned Inspections",
    "Search for Completed Inspections",
    "Search for Inspection History",
  ];
  int searchBarIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  List<dynamic> assignedInspections = [];
  List<dynamic> completedInspections = [];
  List<dynamic> historyInspections = [];
  bool _isloading = true;

  @override
  void initState() {
    super.initState();
    // Fetch inspections from server
    _startSearchBarAnimation();
    fetchInspections();
  }

//   // Fetch inspections data from the server
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
        Uri.parse(
            'http://${dotenv.env['HOST']}/api/inspections/inspector'),
        headers: {"Authorization": 'Bearer ${token}'},
      );

      if (response.statusCode == 200) {
        List<dynamic> inspections = json.decode(response.body);

        // Separate inspections into assigned and completed
        setState(() {
          assignedInspections = inspections
              .where((inspection) => inspection['status'] == 'Pending')
              .toList();
              //these are done but review is remaining
          completedInspections = inspections
              .where((inspection) => inspection['status'] == 'Completed')
              .toList();
          historyInspections = inspections
              .where((inspection) => inspection['status'] == 'Submitted')
              .toList();
              _isloading = false;
        });
      } else {
        throw Exception('Failed to load inspections');
      }
    } catch (e) {
      print('Error fetching inspections: $e');
    }
  }

  // Dummy JSON data
  final List<Map<String, String>> allAssignedInspections = [
  ];

  final List<Map<String, String>> allCompletedInspections = [
  ];

  final List<Map<String, String>> allInspectionHistory = [
  ];

  //   List<Map<String, String>> assignedInspections = [];
  // List<Map<String, String>> completedInspections = [];
  List<Map<String, String>> inspectionHistory = [];

  int _selectedIndex = 0; // Tracks the selected tab index

  void _filterInspections() {
    setState(() {
      // Filter lists based on the search query
      assignedInspections = allAssignedInspections
          .where((inspection) => inspection['vehicleNumber']!
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();

      completedInspections = allCompletedInspections
          .where((inspection) => inspection['vehicleNumber']!
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();

      inspectionHistory = allInspectionHistory
          .where((inspection) => inspection['vehicleNumber']!
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
    });
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected tab
    });
  }

  @override
  // void initState() {
  //   super.initState();
  //   _startSearchBarAnimation();
  // }

  void _startSearchBarAnimation() {
    Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        searchBarIndex = (searchBarIndex + 1) % searchBarTexts.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      _isloading?
      LoadingScreen()
      : 
      Column(
        children: [
          SingleChildScrollView(
            // flex: 1,
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 50),
                  Text(
                    "Inspections",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Find your assigned, completed & history of your all inspections done yet!",
                    // textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  CustomSearchBar(),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),

          // bottom Section
          Expanded(
            flex: 2,
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  // Tab Bar
                  TabBar(
                    onTap: _onTabSelected,
                    dividerColor: Colors.white,
                    indicatorColor: Colors.white, // Remove default indicator
                    labelColor: Colors
                        .white, // Transparent label color (to hide default text styles)
                    unselectedLabelColor:
                        Colors.white, // Hide unselected text color
                    tabs: [
                      _buildCustomTab("Assigned", 0),
                      _buildCustomTab("Completed", 1),
                      _buildCustomTab("History", 2),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Assigned Section
                        assignedInspections.length>0? ListView.builder(
                          itemCount: assignedInspections.length,
                          itemBuilder: (context, index) {
                            return AssignedTaskTile(
                              inspection: assignedInspections[index],
                            );
                          },
                        ):Center(child:
                                  Text("No Inspection Found")
                                ),
                        // Completed Section
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                              child: Container(
                                  child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Filter",
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Icon(Icons.filter_alt)
                                ],
                              )),
                            ),
                            Expanded(
                              child: Container(
                                height: 4000,
                                child: completedInspections.length>0? ListView.builder(
                                  itemCount: completedInspections.length,
                                  itemBuilder: (context, index) {
                                    return TaskTile(
                                     inspection: completedInspections[index],
                                    );
                                    // return buildInspectionCard(completedInspections[index],MediaQuery.of(context).size.width*0.8);
                                  },
                                ):Center(child:
                                  Text("No Inspection Found")
                                )
                              ),
                            ),
                          ],
                        ),

                        // History Section
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                              child: Container(
                                  child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Filter",
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Icon(Icons.filter_alt)
                                ],
                              )),
                            ),
                            Expanded(
                              child: Container(
                                height: 4000,
                                child: historyInspections.length>0? ListView.builder(
                                  itemCount: historyInspections.length,
                                  itemBuilder: (context, index) {
                                    return TaskTile(
                                    inspection: historyInspections[index],
                                    );
                                    // return buildInspectionCard(completedInspections[index],MediaQuery.of(context).size.width*0.8);
                                  },
                                ):Center(child:
                                  Text("No Inspection Found")
                                )
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTab(String label, int index) {
    bool isSelected = _selectedIndex == index;

    return Tab(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor
              : Colors.white, // Orange for selected tab
          borderRadius: BorderRadius.circular(30), // Circular border
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Colors.black, // White for selected text
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class TaskTile extends StatelessWidget {
  final dynamic inspection;

  TaskTile({required this.inspection,});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.black, borderRadius: BorderRadius.circular(25)),
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inspection["inspectionType"]+ "${"  "}"+inspection["subType"] ,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Text("For "+ inspection["customer"]["name"],
                        style: TextStyle(fontSize: 14, color: Colors.white)),
                  ],
                ),
              ),
              Container(child: CalendarWithDate(date: formatDate(inspection["date"])))
            ],
          ),
          // Spacer(),
          SizedBox(
            height: 20,
          ),
          Text(
            '${inspection["status"] ?? 'N/A'}',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Container(child: SimpleLineProgressBar(progress: 1))
        ],
      ),
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
                  color: Colors.black,
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
