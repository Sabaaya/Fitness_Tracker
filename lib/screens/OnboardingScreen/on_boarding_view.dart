import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController controller = PageController();
  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView(
            controller: controller,
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == 2;
              });
            },
            children: [
              _buildPageIndicator(
                  text: 'Meet Your Coach Today, Start Your Journey'
                      .toUpperCase(),
                  imageAsset: 'assets/img/on_1.jpeg'),
              _buildPageIndicator(
                  text: 'CREATE A WORKOUT PLAN TO STAY FIT',
                  imageAsset: 'assets/img/on_2.jpeg'),
              _buildPageIndicator(
                  text: 'ACTION IS THE KEY TO ALL SUCCESS',
                  imageAsset: 'assets/img/on_3.jpeg'),
            ],
          ),
          // Skip Button
          if (!isLastPage)
            Positioned(
              top: size.height * 0.05,
              right: size.width * 0.05,
              child: TextButton(
                onPressed: () {
                  controller.animateToPage(2,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.ease);
                },
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          // Back Button
          Positioned(
            top: size.height * 0.05,
            left: size.width * 0.05,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
          ),
          // Get Started Button
          if (isLastPage)
            Positioned(
              left: size.width * 0.25,
              right: size.width * 0.25,
              bottom: size.height * 0.09,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(208, 253, 62, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/gender');
                },
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          // Page Indicator
          Positioned(
            bottom: size.height * 0.05,
            left: size.width * 0.47,
            child: SmoothPageIndicator(
              controller: controller,
              count: 3,
              effect: const ExpandingDotsEffect(
                dotHeight: 15,
                dotWidth: 15,
                dotColor: Colors.grey,
                activeDotColor: Color.fromRGBO(208, 253, 62, 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator({
    required String text,
    required String imageAsset,
  }) {
    var size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Image.asset(
          imageAsset,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Positioned(
            bottom: 0,
            left: 1,
            child: SizedBox(
              height: size.height * 0.3,
              width: size.width,
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ))
      ],
    );
  }
}
