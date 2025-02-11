import 'package:flutter/material.dart';
import 'package:greenbite_frontend/screens/cart/cart_screen.dart';
import 'package:greenbite_frontend/screens/user_profile/allergies.dart';
import 'package:greenbite_frontend/screens/user_profile/edit_information.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // _________________Top AppBar__________________
      appBar: AppBar(
        title: const Text("GreenBite"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.support_agent),
          onPressed: () {
            print("Support icon tapped");
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const CartScreen()));
            },
          ),
        ],
      ),
      // _________________Top AppBar Ends__________________

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildProfileHeader(),
              const SizedBox(height: 30),
              _buildQuickActions(context),
              const SizedBox(height: 30),
              _buildStats(),
              const SizedBox(height: 30),
              _buildMenuOptions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 60,
          backgroundImage: AssetImage('assets/user.jpg'),
        ),
        const SizedBox(height: 16),
        const Text(
          'Lohan Gunathilaka',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'lohan@jamal.com',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(Icons.calendar_today, 'Activities', context),
        _buildActionButton(Icons.no_food_outlined, 'Allergies', context),
        _buildActionButton(Icons.edit, 'Edit', context),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (label == 'Edit') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditInformation()),
          );
        } else if (label == 'Allergies') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Allergies()),
          );
        }
      },
      child: Container(
        width: 90,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem('0', 'Orders\nin Progress'),
        _buildStatItem('5', 'Total\nOrders'),
        _buildStatItem('35', 'Total\nPoints'),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuOptions() {
    return Column(
      children: [
        _buildMenuButton(Icons.settings, 'Settings'),
        const SizedBox(height: 12),
        // _buildMenuButton(Icons.message, 'Messages'),
        // const SizedBox(height: 12),
        _buildMenuButton(Icons.logout, 'Log out'),
      ],
    );
  }

  Widget _buildMenuButton(IconData icon, String label) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
        onTap: () {},
      ),
    );
  }
}
