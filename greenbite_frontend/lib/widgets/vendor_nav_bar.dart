import 'package:flutter/material.dart';

class VendorNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const VendorNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_rounded),
          label: 'Add',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_rounded),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      onTap: onItemTapped,
      type: BottomNavigationBarType.fixed,
    );
  }
}
