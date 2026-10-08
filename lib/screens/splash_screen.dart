import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(seconds: 3),
          () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Image.asset(
              'assets/images/logo.png',
              width: 180,
              height: 180,
            ),

            const SizedBox(height: 20),


            const Text(
              'Digital Fragrance Identity',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),


            const SizedBox(height: 10),


            const Text(
              'AI Powered Perfume Recommendation',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),


            const SizedBox(height: 30),


            const CircularProgressIndicator(),

          ],
        ),
      ),
    );
  }
}