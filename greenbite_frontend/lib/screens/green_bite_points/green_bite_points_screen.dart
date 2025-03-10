import 'package:flutter/material.dart';
import 'package:greenbite_frontend/config.dart';
import 'package:greenbite_frontend/screens/green_bite_points/green_bite_shop.dart';
import 'package:greenbite_frontend/service/auth_service.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GreenBitePointsScreen extends StatefulWidget {
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
    double progress = (normalPoints / npGoal).clamp(0.0, 1.0);
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: Text("Green Bite Points",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
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
                  _buildTitle(),
                  SizedBox(height: 20),
                  _buildProgressCard(progress),
                  SizedBox(height: 20),
                  _buildGBPCard(),
                  SizedBox(height: 30),
                  _buildShopButton(),
                  SizedBox(height: 30),
                  _buildHowToEarnCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          "Track Your Green Bite Points",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800),
        ),
        SizedBox(height: 5),
        Text(
          "Earn Normal Points (NP) & Convert them to Green Bite Points (GBP)",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildProgressCard(double progress) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: _glassmorphismDecoration(),
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
                      color: Colors.green),
                ),
                SizedBox(height: 5),
                Text("Next: 1 GBP",
                    style:
                        TextStyle(fontSize: 14, color: Colors.grey.shade700)),
              ],
            ),
            progressColor: Colors.green,
            backgroundColor: Colors.grey.shade300,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          SizedBox(height: 15),
          Text(
            "Earn 100 NP to get 1 GBP",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.green.shade800),
          ),
        ],
      ),
    );
  }

  Widget _buildGBPCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: _glassmorphismDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Your Green Bite Points",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700),
          ),
          SizedBox(height: 10),
          Text(
            "$greenBitePoints GBP",
            style: TextStyle(
                fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _buildShopButton() {
    return ElevatedButton.icon(
      icon: Icon(Icons.store, color: Colors.white),
      label: Text("Go to Green Bite Shop"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        elevation: 5,
      ),
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => GreenBiteShopScreen()));
      },
    );
  }

  Widget _buildHowToEarnCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: _glassmorphismDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "How to Earn More NP?",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800),
          ),
          SizedBox(height: 10),
          _buildBulletPoint("Make eco-friendly purchases"),
          _buildBulletPoint("Complete daily challenges"),
          _buildBulletPoint("Refer friends & earn rewards"),
          _buildBulletPoint("Redeem exclusive Green Bite deals"),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 18),
          SizedBox(width: 8),
          Text(text,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade800)),
        ],
      ),
    );
  }

  BoxDecoration _glassmorphismDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        colors: [Colors.white.withOpacity(0.6), Colors.white.withOpacity(0.3)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2),
      ],
    );
  }
}
