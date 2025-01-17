import 'package:flutter/material.dart';
import 'package:wheelwise/components/screens/todays_Inspection.dart';

import 'screens/home_screen.dart';
import 'screens/inspection_page.dart';

class MainAppScreen extends StatefulWidget {
  @override
  _MainAppScreenState createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  // Index of the currently selected widget
  int _selectedIndex = 0;

  // List of widgets to display
  final List<Widget> _widgets = [
    HomePage(),
    InspectionPage(),
    TodaySInspection(),
    // PortfolioWidget(),
    // ProfileWidget(),
  ];

  // Method to handle icon tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Navigation bar widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgets[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        backgroundColor: Colors.black,
        items: [
          BottomNavigationBarItem(
            icon: _buildIcon(0),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(1),
            label: 'Inspection',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(2),
            label: '',
          ),
          // BottomNavigationBarItem(
          //   icon: _buildIcon(3),
          //   label: 'Portfolio',
          // ),
          // BottomNavigationBarItem(
          //   icon: _buildIcon(4),
          //   label: 'Profile',
          // ),
        ],
      ),
    );
  }

  // Helper function to build the icon with style
  Widget _buildIcon(int index) {
    bool isSelected = _selectedIndex == index;
    IconData iconData = _getIconForIndex(index);

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? Colors.white : Colors.black,
      ),
      child: Icon(
        iconData,
        color: isSelected ? Colors.black : Colors.white,
        size: 24,
      ),
    );
  }

  // Helper function to get the icon based on the index
  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.home;
      case 1:
        return Icons.search; // Replace with an "inspection" icon if desired
      case 2:
        return Icons.send;
      // case 3:
      //   return Icons.pie_chart; // Replace with "portfolio" icon
      // case 4:
      //   return Icons.person;
      default:
        return Icons.home;
    }
  }
}


class PortfolioWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Portfolio Widget');
  }
}

class ProfileWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Profile Widget');
  }
}
