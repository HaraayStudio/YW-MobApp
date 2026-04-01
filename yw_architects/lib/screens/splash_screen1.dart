import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);

    _scale = Tween(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _startDelay();
  }

  void _startDelay() async {
    print("Splash Started");

    await Future.delayed(const Duration(seconds: 3));

    print("Splash Finished");

    if (mounted) {
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBEC),
      body: Center(
        child: ScaleTransition(
          scale: _scale,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Y",
                    style: TextStyle(
                      fontSize: 100,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    "W",
                    style: TextStyle(
                      fontSize: 100,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB8952A),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                "YW ARCHITECTS",
                style: TextStyle(
                  fontSize: 18,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(
                color: Color(0xFFB8952A),
              ),
            ],
          ),
        ),
      ),
    );
  }
}