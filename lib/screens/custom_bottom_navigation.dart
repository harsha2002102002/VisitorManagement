
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visitor_management_application/screens/visitors_list_screen.dart';

import '../Color.dart';
import 'QrScannerScreen.dart';
import 'dashboard_screen.dart';

class CustomBottomNavigation extends StatefulWidget {
  const CustomBottomNavigation({super.key});

  @override
  State<CustomBottomNavigation> createState() =>
      _CustomBottomNavigationState();
}

class _CustomBottomNavigationState
    extends State<CustomBottomNavigation> {

  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    VisitorsListScreen(),
  ];

  final List<String> _titles = const [
    'Dashboard',
    'Visitors List',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RequiredColors.Background,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: 0,
        height: 65,
        color: RequiredColors.Primary_Gold,
        buttonBackgroundColor:
        RequiredColors.Primary_Gold,
        backgroundColor:
        RequiredColors.Background,
        animationCurve: Curves.easeInOutCubic,
        animationDuration:
        const Duration(milliseconds: 350),

        items: const [
          Icon(
            Icons.dashboard_rounded,
            size: 28,
            color: Colors.white,
          ),
          Icon(
            Icons.people_alt_rounded,
            size: 28,
            color: Colors.white,
          ),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}




