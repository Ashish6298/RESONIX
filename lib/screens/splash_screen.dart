import 'dart:async'; // Required for the Timer
import 'package:flutter/material.dart';
import 'home_screen.dart'; // Import your Home Screen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait for 3 seconds, then navigate to HomeScreen
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Use the same Gradient as your PlayerScreen for consistency
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade900,
              const Color(0xFF121212), // Deep black-grey
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.music_note_rounded,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              Text(
                "RESONIX",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 5.0, // Wide spacing looks modern
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Feel the Music",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white54,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}