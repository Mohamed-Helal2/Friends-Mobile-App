import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:test1/core/routes/routes.dart';
import 'package:test1/core/utils/extension.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 2000), () {
      context.pushNamed(Routes.loginScreen);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Lottie.asset(
          'assets/splash/friends.json',
          height: 250,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
