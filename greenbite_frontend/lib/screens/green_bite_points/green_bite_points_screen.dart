import 'package:flutter/material.dart';
import 'package:greenbite_frontend/config.dart';
import 'package:greenbite_frontend/screens/green_bite_points/green_bite_shop.dart';
import 'package:greenbite_frontend/service/auth_service';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GreenBitePointsScreen extends StatefulWidget {
  const GreenBitePointsScreen({super.key});

  @override
  _GreenBitePointsScreenState createState() => _GreenBitePointsScreenState();
}

class _GreenBitePointsScreenState extends State<GreenBitePointsScreen> {
  int normalPoints = 0;
  int greenBitePoints = 0;
  int npGoal = 100;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPoints();
  }

  Future<Map<String, String>> _getHeaders() async {
    String? token = await AuthService.getToken();
    if (token == null) throw Exception("No JWT token found.");
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Future<void> _fetchPoints() async {
    setState(() => isLoading = true);

    try {
      int? userId = await AuthService.getUserId();
      if (userId == null) throw Exception('User ID not found');

      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/api/users/points?userId=$userId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          normalPoints = data['normalPoints'];
          greenBitePoints = data['greenBitePoints'];
        });
      } else {
        _showSnackBar("Failed to fetch points: ${response.body}");
      }
    } catch (e) {
      _showSnackBar("Error fetching points: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    double progress = (normalPoints / npGoal).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: isDarkMode
          ? Colors.grey[900]
          : Colors.green.shade50, // ✅ Adaptive background color
      appBar: AppBar(
        title: Text(
          "Green Bite Points",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green, // ✅ Keep green for AppBar
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white, // ✅ Keep white icons for AppBar
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchPoints,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.green))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildTitle(isDarkMode),
                  const SizedBox(height: 20),
                  _buildProgressCard(progress, isDarkMode),
                  const SizedBox(height: 20),
                  _buildGBPCard(isDarkMode),
                  const SizedBox(height: 30),
                  _buildShopButton(),
                  const SizedBox(height: 30),
                  _buildHowToEarnCard(isDarkMode),
                ],
              ),
            ),
    );
  }

  Widget _buildTitle(bool isDarkMode) {
    return Column(
      children: [
        Text(
          "Track Your Green Bite Points",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDarkMode
                ? Colors.white
                : Colors.green.shade800, // ✅ Adaptive text color
          ),
        ),
        const SizedBox(height: 5),
        Text(
          "Earn Normal Points (NP) & Convert them to Green Bite Points (GBP)",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode
                ? Colors.grey[400]
                : Colors.grey[700], // ✅ Adaptive text color
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(double progress, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _glassmorphismDecoration(isDarkMode),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularPercentIndicator(
            radius: 120.0,
            lineWidth: 12.0,
            animation: true,
            percent: progress,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$normalPoints / $npGoal NP",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    color: Colors.green, // ✅ Keep green for progress text
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Next: 1 GBP",
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode
                        ? Colors.grey[400]
                        : Colors.grey[700], // ✅ Adaptive text color
                  ),
                ),
              ],
            ),
            progressColor: Colors.green, // ✅ Keep green for progress bar
            backgroundColor: isDarkMode
                ? Colors.grey[800]!
                : Colors.grey[300]!, // ✅ Adaptive background color
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 15),
          Text(
            "Earn 100 NP to get 1 GBP",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDarkMode
                  ? Colors.white
                  : Colors.green.shade800, // ✅ Adaptive text color
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGBPCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _glassmorphismDecoration(isDarkMode),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Your Green Bite Points",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode
                  ? Colors.grey[400]
                  : Colors.grey[700], // ✅ Adaptive text color
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "$greenBitePoints GBP",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.green, // ✅ Keep green for GBP text
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.store, color: Colors.white),
      label: const Text("Go to Green Bite Shop"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green, // ✅ Keep green for button
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        elevation: 5,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GreenBiteShopScreen()),
        );
      },
    );
  }

  Widget _buildHowToEarnCard(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _glassmorphismDecoration(isDarkMode),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "How to Earn More NP?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode
                  ? Colors.white
                  : Colors.green.shade800, // ✅ Adaptive text color
            ),
          ),
          const SizedBox(height: 10),
          _buildBulletPoint("Make eco-friendly purchases", isDarkMode),
          _buildBulletPoint("Complete daily challenges", isDarkMode),
          _buildBulletPoint("Refer friends & earn rewards", isDarkMode),
          _buildBulletPoint("Redeem exclusive Green Bite deals", isDarkMode),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle,
              color: Colors.green, size: 18), // ✅ Keep green for bullet icon
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode
                  ? Colors.grey[400]
                  : Colors.grey[800], // ✅ Adaptive text color
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _glassmorphismDecoration(bool isDarkMode) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        colors: [
          isDarkMode ? Colors.grey[850]! : Colors.white.withOpacity(0.6),
          isDarkMode ? Colors.grey[900]! : Colors.white.withOpacity(0.3),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.green.withOpacity(0.1),
          blurRadius: 15,
          spreadRadius: 2,
        ),
      ],
    );
  }
}
