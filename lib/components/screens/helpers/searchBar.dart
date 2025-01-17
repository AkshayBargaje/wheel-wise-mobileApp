import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wheelwise/utils/const.dart';

class CustomSearchBar extends StatefulWidget {
  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  String searchQuery = '';
  List<Map<String, dynamic>> inspections = []; // Example list
  List<Map<String, dynamic>> tasks = []; // Example list
  final List<String> searchBarTexts = [
    "Search for Assigned Inspections",
    "Search for Completed Inspections",
    "Search for Inspection History",
  ];
    int searchBarIndex = 0;
  List<Map<String, dynamic>> filteredInspections = [];
  List<Map<String, dynamic>> filteredTasks = [];

 @override
  void initState() {
    super.initState();
    _startSearchBarAnimation();
  }

  void _startSearchBarAnimation() {
    Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        searchBarIndex = (searchBarIndex + 1) % searchBarTexts.length;
      });
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return Container(
decoration: BoxDecoration(
        color: Colors.white,

borderRadius: BorderRadius.circular(40)
),      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: TextField(
          key: ValueKey(searchBarTexts[searchBarIndex]),
          decoration: InputDecoration(
            hintText: searchBarTexts[searchBarIndex],
            prefixIcon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                AppAssets.search_icon, // Replace with your SVG asset
                width: 20,
                height: 20,
              ),
            ),
            suffixIcon: Container(
              padding: EdgeInsets.fromLTRB(8, 12, 10, 8),
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: Colors.black,
                // shape: BoxShape.circle,
                borderRadius: BorderRadius.circular(50)
              ),
              child: SvgPicture.asset(
                AppAssets.search_icon2,
                width: 15,
                height: 15,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(200),
            ),
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value.toLowerCase();
              filteredInspections = inspections
                  .where((inspection) => inspection['carName']!
                      .toLowerCase()
                      .contains(searchQuery))
                  .toList();
              filteredTasks = tasks
                  .where((task) =>
                      task['title']!.toLowerCase().contains(searchQuery))
                  .toList();
        
              // Update the hint text every time the user types
            });
          },
        ),
      ),
    );
  }
}
