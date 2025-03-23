import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Add lottie package to your pubspec.yaml
import 'package:greenbite_frontend/screens/login/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // Onboarding data with Lottie animations
  final List<Map<String, String>> onboardingData = [
    {
      "animation": "assets/animations/join.json",
      "title": "Discover Tasty Meals",
      "description":
          "Enjoy delicious, high-quality meals from top restaurants while reducing food waste.",
    },
    {
      "animation": "assets/animations/food_plate_animation.json",
      "title": "Save Money, Eat Smart",
      "description":
          "Get surplus meals at discounted prices and make sustainable dining affordable for all.",
    },
    {
      "animation": "assets/animations/community.json",
      "title": "Join the Green Movement",
      "description":
          "Support local businesses and help create a greener planet by reducing food waste.",
    },
    {
      "animation": "assets/animations/find.json",
      "title": "Convenient & Sustainable Food",
      "description":
          "Order surplus meals easily and get them delivered straight to your door.",
    },
  ];

  void _nextPage() {
    if (_currentIndex < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to Login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _skipOnboarding() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface, //  Theme-based background
      body: Stack(
        children: [
          // PageView for onboarding screens
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingData.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 100),
                    // Lottie Animation
                    Lottie.asset(
                      onboardingData[index]["animation"]!,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 40),
                    // Title
                    Text(
                      onboardingData[index]["title"]!,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme
                            .colorScheme.onSurface, //  Adaptive text color
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // Description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        onboardingData[index]["description"]!,
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.onSurface
                              .withOpacity(0.8), //  Adaptive text color
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Skip Button (Top Right)
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: _skipOnboarding,
              child: Text(
                "Skip",
                style: TextStyle(
                  fontSize: 16,
                  color:
                      theme.colorScheme.onSurface, //  Adaptive text color
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Page Indicators (Bottom Center)
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? theme.colorScheme.primary //  Adaptive color
                        : theme.colorScheme.onSurface
                            .withOpacity(0.3), //  Adaptive color
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),

          // Next Button (Bottom Center)
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary, //  Adaptive color
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentIndex == onboardingData.length - 1
                    ? "Get Started"
                    : "Next",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary, //  Adaptive text color
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
