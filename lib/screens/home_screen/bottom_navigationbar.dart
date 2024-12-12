import 'package:fitness/constants/color.dart';
import 'package:fitness/login/profilepage.dart';

import 'package:fitness/screens/home_screen/notifications.dart';
import 'package:fitness/screens/home_screen/home_screen.dart';
import 'package:fitness/screens/home_screen/workout_progress.dart';
import 'package:fitness/tip/tips_view.dart';

import 'package:flutter/material.dart';

class HomepageNavbar extends StatefulWidget {
  const HomepageNavbar({super.key});

  @override
  State<HomepageNavbar> createState() => _HomepageNavbarState();
}

class _HomepageNavbarState extends State<HomepageNavbar> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
      const AdminHomeScreen(),
  const WorkoutProgress(),
     const NotificationPage(),
    const ProfilePage(),
    const TipsView()
  ];

    void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.black, // Set the background color here
              selectedItemColor: Color.fromARGB(255, 5, 68, 7),
              unselectedItemColor: Color.fromARGB(255, 4, 38, 67),
              showSelectedLabels: true,
              showUnselectedLabels: true,
            ),
          
          ),
        child: BottomNavigationBar(
          
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            
            BottomNavigationBarItem(
              icon: Icon(Icons.poll),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_active_sharp),
              label: 'Notifications',
            ),
            
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: PrimaryColor,
          unselectedItemColor: const Color.fromARGB(255, 6, 71, 11),
          onTap: _onItemTapped,
        ),
      ),),
    );
  }
}
