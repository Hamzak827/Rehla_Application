import 'package:flutter/material.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart'; // Make sure this import is correct
import 'package:Rehla/map/map_screen.dart';
import '../main.dart';
import '../screens/bookings/booking_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/tours/home_screen.dart';

class NavigationBars extends StatefulWidget {
  const NavigationBars({super.key});
  static const routeName = '/navigation-screen';

  @override
  State<NavigationBars> createState() => _NavigationBarsState();
}

class _NavigationBarsState extends State<NavigationBars> {
  late NotchBottomBarController _controller;
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    BookingScreen(),
    MapScreen(),
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
          color: Colors.transparent, 
          // Make the background invisible
        ),
        child: AnimatedNotchBottomBar(
          notchBottomBarController: _controller,
          bottomBarItems: [
            BottomBarItem(
              inActiveItem: const Icon(Icons.home_outlined, color: Color.fromARGB(255, 241, 243, 243)),
              activeItem: const Icon(Icons.home, color:  Color.fromRGBO(61,115,127,4)),
              itemLabel: 'Home',
            ),
            BottomBarItem(
              inActiveItem: const Icon(Icons.airplane_ticket_outlined, color: Color.fromARGB(255, 240, 241, 241)),
              activeItem: const Icon(Icons.airplane_ticket, color:  Color.fromRGBO(61,115,127,4)),
              itemLabel: 'Bookings',
            ),BottomBarItem(
              inActiveItem: const Icon(Icons.map_outlined, color: Color.fromARGB(255, 245, 246, 246)),
              activeItem: const Icon(Icons.map, color:  Color.fromRGBO(61,115,127,4)),
              itemLabel: 'Map',
            ),
            BottomBarItem(
              inActiveItem: const Icon(Icons.person_outlined, color: Color.fromARGB(255, 250, 250, 250)),
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


