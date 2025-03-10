import 'package:flutter/material.dart';
import '../../widgets/custom_button_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/image.png",
      "title": "Welcome to GreenBite",
      "description":
          "Order surplus food from restaurants at a discount and help reduce food waste!",
    },
    {
      "image": "assets/image.png",
      "title": "Support Sustainability",
      "description":
          "Contribute to a greener future by reducing food wastage and saving delicious meals.",
    },
    {
      "image": "assets/image.png",
      "title": "Join the Community",
      "description":
          "Be part of the change and enjoy great food while making a positive impact.",
    },
  ];

  void _nextPage() {
    if (_currentIndex < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: onboardingData.length,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Image.asset(
                        onboardingData[index]["image"]!,
                        height: 250,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      onboardingData[index]["title"]!,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        onboardingData[index]["description"]!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: CustomButton(
              text: _currentIndex == onboardingData.length - 1
                  ? "Get Started"
                  : "Next",
              onPressed: _nextPage,
              backgroundColor: Colors.green,
              textColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
