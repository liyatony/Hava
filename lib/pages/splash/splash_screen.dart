// splash_screen.dart
import 'package:flutter/material.dart';
import 'package:hava/pages/home/weather_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToWeatherPage();
  }

  void _navigateToWeatherPage() {
    Future.delayed(const Duration(seconds: 6), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    });
  }

  @override
 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      // Enhanced purple gradient background with three colors
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFAF82F5), // Slightly darker light purple
            Color(0xFF9A4FE6), // Slightly darker medium purple
            Color(0xFF7A1BD2), // Slightly darker deep purple 
          ],
          
          stops: [0.0, 0.55, 1.0], // Control the gradient distribution
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo in the center
              Container(
                width: 400,
                height: 400,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Image.asset(
                  'assets/icons/HAVA.png',
                  color: Colors.white,
                ),
              ),
              
              // Add a simple loading indicator for modern touch
              
            ],
          ),
        ),
      ),
    ),
  );
}}