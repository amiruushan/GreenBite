import 'package:flutter/material.dart';

class StoreDashboard extends StatelessWidget {
  const StoreDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Store Dashboard',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileSection(),
            const SizedBox(height: 30),
            _buildStats(),
            const SizedBox(height: 30),
            _buildMenuButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundImage: AssetImage('assets/store.jpg'),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Street-Za',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'streetza@mail.com',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Edit',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem('3', 'Active\nListings'),
        _buildStatItem('5', 'Food to be\ndelivered'),
        _buildStatItem('35', 'Total\nPoints'),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
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
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButtons() {
    return Column(
      children: [
        _buildMenuButton(
          'List a Product',
          Icons.add_circle_outline,
          color: Colors.green,
        ),
        const SizedBox(height: 12),
        _buildMenuButton(
          'Manage Listings',
          Icons.list_alt_outlined,
          color: Colors.green,
        ),
        const SizedBox(height: 12),
        _buildMenuButton(
          'Store Information',
          Icons.store_outlined,
          color: Colors.green,
        ),
        const SizedBox(height: 12),
        _buildMenuButton(
          'Pending Orders',
          Icons.access_time,
          color: Colors.green,
        ),
        const SizedBox(height: 12),
        _buildMenuButton(
          'Completed Orders',
          Icons.check_box_outlined,
          color: Colors.green,
        ),
        const SizedBox(height: 24),
        _buildMenuButton(
          'Sign Out',
          Icons.logout,
          color: Colors.red[300]!,
        ),
      ],
    );
  }

  Widget _buildMenuButton(String label, IconData icon, {required Color color}) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color == Colors.red[300] ? Colors.red : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (color != Colors.red[300])
                  Icon(
                    Icons.arrow_forward_ios,
                    color: color,
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
