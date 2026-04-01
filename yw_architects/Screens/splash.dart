import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate after animation
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8), // soft architectural beige
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // 🔥 Animated Logo
            SizedBox(
              height: 180,
              child: Lottie.asset(
                'assets/animations/yw_splash.json',
                fit: BoxFit.contain,
                repeat: false,
              ),
            ),

            const SizedBox(height: 20),

            // Company Name
            const Text(
              "YW ARCHITECTS",
              style: TextStyle(
                fontSize: 16,
                letterSpacing: 3,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 40),

            // Optional subtle loader
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}