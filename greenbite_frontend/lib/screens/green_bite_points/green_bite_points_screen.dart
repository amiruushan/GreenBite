import 'package:flutter/material.dart';
import 'package:greenbite_frontend/config.dart';
import 'package:greenbite_frontend/screens/green_bite_points/green_bite_shop.dart';
import 'package:greenbite_frontend/service/auth_service.dart';
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
    final isDarkMode = theme.brightness == Brightness.dark;

    double progress = (normalPoints / npGoal).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface, // ✅ Theme-based background
      appBar: AppBar(
        title: Text(
          "Green Bite Points",
          style: TextStyle(
            color: theme.colorScheme.onSurface, // ✅ Adaptive text color
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // ✅ Transparent AppBar
        elevation: 0, // ✅ Remove shadow
        iconTheme: IconThemeData(
          color: theme.colorScheme.onSurface, // ✅ Icons adapt to theme
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: theme.colorScheme.onSurface, // ✅ Action icons adapt
            ),
            onPressed: _fetchPoints,
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary, // ✅ Theme-based color
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildTitle(theme),
                  const SizedBox(height: 20),
                  _buildProgressCard(progress, theme),
                  const SizedBox(height: 20),
                  _buildGBPCard(theme),
                  const SizedBox(height: 30),
                  _buildShopButton(theme),
                  const SizedBox(height: 30),
                  _buildHowToEarnCard(theme),
                ],
              ),
            ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Column(
      children: [
        Text(
          "Track Your Green Bite Points",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface, // ✅ Adaptive text color
          ),
        ),
        const SizedBox(height: 5),
        Text(
          "Earn Normal Points (NP) & Convert them to Green Bite Points (GBP)",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurface
                .withOpacity(0.7), // ✅ Adaptive text color
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(double progress, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _glassmorphismDecoration(theme),
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
                    color: theme.colorScheme.primary, // ✅ Theme-based color
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Next: 1 GBP",
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface
                        .withOpacity(0.7), // ✅ Adaptive text color
                  ),
                ),
              ],
            ),
            progressColor: theme.colorScheme.primary, // ✅ Theme-based color
            backgroundColor:
                theme.colorScheme.surfaceContainerHighest, // ✅ Theme-based color
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 15),
          Text(
            "Earn 100 NP to get 1 GBP",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface, // ✅ Adaptive text color
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGBPCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _glassmorphismDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Your Green Bite Points",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface
                  .withOpacity(0.7), // ✅ Adaptive text color
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "$greenBitePoints GBP",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary, // ✅ Theme-based color
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopButton(ThemeData theme) {
    return ElevatedButton.icon(
      icon: Icon(
        Icons.store,
        color: theme.colorScheme.onPrimary, // ✅ Theme-based color
      ),
      label: Text(
        "Go to Green Bite Shop",
        style: TextStyle(
          color: theme.colorScheme.onPrimary, // ✅ Theme-based color
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary, // ✅ Theme-based color
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

  Widget _buildHowToEarnCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _glassmorphismDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "How to Earn More NP?",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface, // ✅ Adaptive text color
            ),
          ),
          const SizedBox(height: 10),
          _buildBulletPoint("Make eco-friendly purchases", theme),
          _buildBulletPoint("Complete daily challenges", theme),
          _buildBulletPoint("Refer friends & earn rewards", theme),
          _buildBulletPoint("Redeem exclusive Green Bite deals", theme),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            color: theme.colorScheme.primary, // ✅ Theme-based color
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface
                  .withOpacity(0.7), // ✅ Adaptive text color
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _glassmorphismDecoration(ThemeData theme) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        colors: [
          theme.colorScheme.surface.withOpacity(0.6),
          theme.colorScheme.surface.withOpacity(0.3),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: theme.colorScheme.primary.withOpacity(0.1),
          blurRadius: 15,
          spreadRadius: 2,
        ),
      ],
    );
  }
}
