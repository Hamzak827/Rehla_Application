import 'package:flutter/material.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart'; // Import the AnimatedNotchBottomBar package
import 'package:Rehla/screens/admin/admin_tours.dart';
import '../main.dart';
import '../screens/admin/admin_bookings.dart';
import '../screens/admin/admin_home.dart';
import '../screens/profile/profile_screen.dart';

class AdminNavigationBars extends StatefulWidget {
  const AdminNavigationBars({super.key});
  static const routeName = '/admin-navigation-screen';

  @override
  State<AdminNavigationBars> createState() => _AdminNavigationBarsState();
}

class _AdminNavigationBarsState extends State<AdminNavigationBars> {
  late NotchBottomBarController _controller;
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    AdminHome(),
    AdminTours(),
    const AdminBookings(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _controller = NotchBottomBarController();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _controller.index = index; // Ensure the controller reflects the change
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 90.0, // Control the height here
        decoration: BoxDecoration(
          color: Colors.transparent, // Make the background invisible
        ),
        child: AnimatedNotchBottomBar(
          notchBottomBarController: _controller,
          bottomBarItems: [
            BottomBarItem(
              inActiveItem: const Icon(Icons.dashboard_outlined, color: Color.fromARGB(255, 250, 252, 253)),
              activeItem: const Icon(Icons.dashboard, color:  Color.fromRGBO(61,115,127,4)),
              itemLabel: 'Dashboard',
            ),
            BottomBarItem(
              inActiveItem: const Icon(Icons.travel_explore_outlined, color: Color.fromARGB(255, 250, 252, 253)),
              activeItem: const Icon(Icons.travel_explore, color:  Color.fromRGBO(61,115,127,4)),
              itemLabel: 'Tours',
            ),
            BottomBarItem(
              inActiveItem: const Icon(Icons.airplane_ticket_outlined, color: Color.fromARGB(255, 252, 252, 252)),
              activeItem: const Icon(Icons.airplane_ticket, color:  Color.fromRGBO(61,115,127,4)),
              itemLabel: 'Bookings',
            ),
            BottomBarItem(
              inActiveItem: const Icon(Icons.person_outline, color: Color.fromARGB(255, 246, 246, 246)),
              activeItem: const Icon(Icons.person, color:  Color.fromRGBO(61,115,127,4)),
              itemLabel: 'Profile',
            ),
          ],
          onTap: _onItemTapped,
          color:  Color.fromRGBO(61,115,127,4),
          durationInMilliSeconds: 100,
          showLabel:false
          // Set bottom bar color to transparent
        ),
      ),
    );
  }
}


