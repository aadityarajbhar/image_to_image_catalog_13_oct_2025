import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_to_image_catalog/const/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home_screen/home_screen.dart';
import '../login_screen/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleSplashLogic(context);
    });
  }

  Future<void> _handleSplashLogic(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));

    if (!context.mounted) return;

    final isLoggedIn = await checkLoginStatus();

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (context) =>
            isLoggedIn ? const HomeScreen() : const LoginScreen(),
      ),
    );
  }

  Future<bool> checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('isLoggedIn') ?? false;
    } catch (e) {
      debugPrint('Error checking login status: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      body: Container(
        color: AppColors().primary,
        height: height,
        width: width,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/Group 1.png",
                height: height * 0.25,
                width: width * 0.5,
              ),
              SizedBox(
                height: height * 0.01,
              ),
              Text(
                "Image To Image Catalog",
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: width * 0.06,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
