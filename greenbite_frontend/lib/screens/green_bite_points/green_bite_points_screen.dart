import 'package:flutter/material.dart';
import 'package:greenbite_frontend/screens/green_bite_points/green_bite_shop.dart';
import 'package:greenbite_frontend/service/auth_service';
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

  Future<void> _fetchPoints() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Get the user ID from AuthService
      int? userId = await AuthService.getUserId();
      if (userId == null) {
        throw Exception('User ID not found');
      }

      // Fetch points using the user ID
      final response = await http.get(
        Uri.parse('http://192.168.1.2:8080/api/user/points?userId=$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          normalPoints = data['normalPoints'];
          greenBitePoints = data['greenBitePoints'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch points: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching points: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress = normalPoints / npGoal;

    return Scaffold(
      appBar: AppBar(
        title: Text("Green Bite Points"),
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchPoints,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularPercentIndicator(
                    radius: 120.0,
                    lineWidth: 15.0,
                    animation: true,
                    percent: progress.clamp(0.0, 1.0),
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("$normalPoints / $npGoal NP",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                                color: Colors.green)),
                        SizedBox(height: 5),
                        Text("Next: 1 GBP",
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                    progressColor: Colors.green,
                    backgroundColor: Colors.grey.shade200,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Green Bite Points: $greenBitePoints",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: Icon(Icons.store),
                    label: Text("Go to Green Bite Shop"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding:
                          EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GreenBiteShopScreen()));
                    },
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
