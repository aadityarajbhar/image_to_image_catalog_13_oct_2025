// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:image_to_image_catalog/const/app_colors.dart';
// // import 'package:shared_preferences/shared_preferences.dart';

// // import '../home_screen/home_screen.dart';
// // import '../login_screen/login_screen.dart';

// // class SplashScreen extends StatelessWidget {
// //   const SplashScreen({super.key});

// //   Future<bool> checkLoginStatus() async {
// //     try {
// //       final prefs = await SharedPreferences.getInstance();
// //       return prefs.getBool('isLoggedIn') ?? false;
// //     } catch (e) {
// //       debugPrint('Error checking login status: $e');
// //       return false;
// //     }
// //   }

// //   void changeScreen(BuildContext context) async {
// //     // Wait for the splash screen duration
// //     await Future.delayed(const Duration(seconds: 2));

// //     if (!context.mounted) return;

// //     // Check login status
// //     final isLoggedIn = await checkLoginStatus();

// //     if (!context.mounted) return;

// //     // Navigate to appropriate screen based on login status
// //     Navigator.pushReplacement(
// //       context,
// //       CupertinoPageRoute(
// //         builder: (context) =>
// //             isLoggedIn ? const HomeScreen() : const LoginScreen(),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // Store MediaQuery values in variables for cleaner code
// //     final size = MediaQuery.of(context).size;
// //     final height = size.height;
// //     final width = size.width;

// //     // Call screen change after frame is built
// //     WidgetsBinding.instance.addPostFrameCallback(
// //       (_) {
// //         changeScreen(context);
// //       },
// //     );

// //     return Scaffold(
// //       body: Container(
// //         color: AppColors().primary,
// //         height: height,
// //         width: width,
// //         child: Center(
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             crossAxisAlignment: CrossAxisAlignment.center,
// //             children: [
// //               Image.asset(
// //                 "assets/images/Group 1.png",
// //                 height: height * 0.25,
// //                 width: width * 0.5,
// //               ),
// //               SizedBox(
// //                 height: height * 0.01,
// //               ),
// //               Text(
// //                 "Image To Image Catalog",
// //                 style: GoogleFonts.manrope(
// //                   color: Colors.white,
// //                   fontSize: width * 0.06,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // // import 'dart:developer';
// // // import 'package:flutter/cupertino.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:google_fonts/google_fonts.dart';
// // // import 'package:package_info_plus/package_info_plus.dart';
// // // import 'package:shared_preferences/shared_preferences.dart';
// // // import 'package:url_launcher/url_launcher.dart';
// // // import '../../const/app_colors.dart';
// // // import '../home_screen/home_screen.dart';
// // // import '../login_screen/login_screen.dart';

// // // /// ✅ Version Comparison Helper
// // // class ForceUpdateHelper {
// // //   static bool isVersionGreater(String minRequired, String current) {
// // //     final minClean = minRequired.replaceAll('+', '.');
// // //     final currClean = current.replaceAll('+', '.');

// // //     final minParts = minClean.split('.').map(int.parse).toList();
// // //     final currParts = currClean.split('.').map(int.parse).toList();

// // //     for (int i = 0; i < minParts.length; i++) {
// // //       if (i >= currParts.length) return true;
// // //       if (minParts[i] > currParts[i]) return true;
// // //       if (minParts[i] < currParts[i]) return false;
// // //     }
// // //     return false;
// // //   }
// // // }

// // // class SplashScreen extends StatefulWidget {
// // //   const SplashScreen({super.key});

// // //   @override
// // //   State<SplashScreen> createState() => _SplashScreenState();
// // // }

// // // class _SplashScreenState extends State<SplashScreen> {
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     WidgetsBinding.instance.addPostFrameCallback((_) => _checkVersion());
// // //   }

// // //   Future<void> _checkVersion() async {
// // //     try {
// // //       final packageInfo = await PackageInfo.fromPlatform();
// // //       final currentVersion = '1.7.0';

// // //       const minRequiredVersion = '1.8.0'; // Change this to your latest build

// // //       log("Current version: $currentVersion | Min required: $minRequiredVersion");

// // //       final shouldUpdate = ForceUpdateHelper.isVersionGreater(
// // //         minRequiredVersion,
// // //         currentVersion,
// // //       );

// // //       if (shouldUpdate) {
// // //         _showForceUpdateDialog();
// // //       } else {
// // //         await Future.delayed(const Duration(seconds: 2));
// // //         await _navigateToNextScreen();
// // //       }
// // //     } catch (e) {
// // //       log("Version check error: $e");
// // //       await Future.delayed(const Duration(seconds: 2));
// // //       await _navigateToNextScreen();
// // //     }
// // //   }

// // //   Future<void> _navigateToNextScreen() async {
// // //     try {
// // //       final prefs = await SharedPreferences.getInstance();
// // //       final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

// // //       if (!mounted) return;

// // //       Navigator.pushReplacement(
// // //         context,
// // //         CupertinoPageRoute(
// // //           builder: (_) => isLoggedIn ? const HomeScreen() : const LoginScreen(),
// // //         ),
// // //       );
// // //     } catch (e) {
// // //       log('Navigation error: $e');
// // //     }
// // //   }

// // //   void _showForceUpdateDialog() {
// // //     showDialog(
// // //       context: context,
// // //       barrierDismissible: false,
// // //       builder: (_) => AlertDialog(
// // //         title: const Text("Update Required"),
// // //         content: const Text(
// // //           "A new version of the app is available.\nPlease update to continue.",
// // //         ),
// // //         actions: [
// // //           TextButton(
// // //             onPressed: () async {
// // //               const url =
// // //                   "https://play.google.com/store/apps/details?id=com.techflux.imagetoimagecatalog";
// // //               if (await canLaunchUrl(Uri.parse(url))) {
// // //                 await launchUrl(
// // //                   Uri.parse(url),
// // //                   mode: LaunchMode.externalApplication,
// // //                 );
// // //               } else {
// // //                 log("❌ Could not launch update URL");
// // //               }
// // //             },
// // //             child: const Text("Update Now"),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final size = MediaQuery.of(context).size;
// // //     final height = size.height;
// // //     final width = size.width;

// // //     return Scaffold(
// // //       body: Container(
// // //         color: AppColors().primary,
// // //         height: height,
// // //         width: width,
// // //         child: Center(
// // //           child: Column(
// // //             mainAxisAlignment: MainAxisAlignment.center,
// // //             children: [
// // //               Image.asset(
// // //                 "assets/images/Group 1.png",
// // //                 height: height * 0.25,
// // //                 width: width * 0.5,
// // //               ),
// // //               SizedBox(height: height * 0.01),
// // //               Text(
// // //                 "Image To Image Catalog",
// // //                 style: GoogleFonts.manrope(
// // //                   color: Colors.white,
// // //                   fontSize: width * 0.06,
// // //                   fontWeight: FontWeight.bold,
// // //                 ),
// // //               ),
// // //               // const SizedBox(height: 20),
// // //               // const CircularProgressIndicator(color: Colors.white),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }

// import 'dart:io';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_to_image_catalog/const/app_colors.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:in_app_update/in_app_update.dart';
// import 'package:upgrader/upgrader.dart';
// import '../home_screen/home_screen.dart';
// import '../login_screen/login_screen.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Check for updates and navigate after frame is built
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _handleSplashLogic(context);
//     });
//   }

//   Future<void> _handleSplashLogic(BuildContext context) async {
//     // Wait for the splash screen duration
//     await Future.delayed(const Duration(seconds: 2));

//     if (!context.mounted) return;

//     // Check for updates
//     await checkForUpdate(context);

//     if (!context.mounted) return;

//     // Check login status
//     final isLoggedIn = await checkLoginStatus();

//     if (!context.mounted) return;

//     // Navigate to appropriate screen
//     Navigator.pushReplacement(
//       context,
//       CupertinoPageRoute(
//         builder: (context) =>
//             isLoggedIn ? const HomeScreen() : const LoginScreen(),
//       ),
//     );
//   }

//   Future<bool> checkLoginStatus() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       return prefs.getBool('isLoggedIn') ?? false;
//     } catch (e) {
//       debugPrint('Error checking login status: $e');
//       return false;
//     }
//   }

//   Future<void> checkForUpdate(BuildContext context) async {
//     if (Platform.isAndroid) {
//       try {
//         AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
//         if (updateInfo.updateAvailability ==
//             UpdateAvailability.updateAvailable) {
//           if (updateInfo.immediateUpdateAllowed) {
//             // Perform an immediate update (forced update)
//             await InAppUpdate.performImmediateUpdate();
//           } else if (updateInfo.flexibleUpdateAllowed) {
//             // Perform a flexible update
//             await InAppUpdate.startFlexibleUpdate();
//             if (context.mounted) {
//               showDialog(
//                 context: context,
//                 builder: (context) => AlertDialog(
//                   title: const Text('Update Downloaded'),
//                   content:
//                       const Text('Please complete the update to continue.'),
//                   actions: [
//                     TextButton(
//                       onPressed: () async {
//                         await InAppUpdate.completeFlexibleUpdate();
//                       },
//                       child: const Text('Install Now'),
//                     ),
//                   ],
//                 ),
//               );
//             }
//           }
//         }
//       } catch (e) {
//         debugPrint("Error checking for update: $e");
//         if (context.mounted) {
//           // Fallback to upgrader for Android if in_app_update fails
//           // Upgrader().checkVersion(context: context);
//         }
//       }
//     }
//     // iOS relies on Upgrader (handled by UpgradeAlert in main.dart)
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Store MediaQuery values for cleaner code
//     final size = MediaQuery.of(context).size;
//     final height = size.height;
//     final width = size.width;

//     return Scaffold(
//       body: Container(
//         color: AppColors().primary,
//         height: height,
//         width: width,
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Image.asset(
//                 "assets/images/Group 1.png",
//                 height: height * 0.25,
//                 width: width * 0.5,
//               ),
//               SizedBox(
//                 height: height * 0.01,
//               ),
//               Text(
//                 "Image To Image Catalog",
//                 style: GoogleFonts.manrope(
//                   color: Colors.white,
//                   fontSize: width * 0.06,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_to_image_catalog/const/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_update/in_app_update.dart';
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
    // Wait for splash screen duration
    await Future.delayed(const Duration(seconds: 2));

    if (!context.mounted) return;

    // Check for updates (Android only; iOS and fallback handled by UpgradeAlert in main.dart)
    if (Platform.isAndroid) {
      await checkForUpdate(context);
    }

    if (!context.mounted) return;

    // Check login status
    final isLoggedIn = await checkLoginStatus();

    if (!context.mounted) return;

    // Navigate to appropriate screen
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

  Future<void> checkForUpdate(BuildContext context) async {
    try {
      AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateUpdateAllowed) {
          // Perform an immediate update (forced update)
          await InAppUpdate.performImmediateUpdate();
        } else if (updateInfo.flexibleUpdateAllowed) {
          // Perform a flexible update
          await InAppUpdate.startFlexibleUpdate();
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Update Downloaded'),
                content: const Text('Please complete the update to continue.'),
                actions: [
                  TextButton(
                    onPressed: () async {
                      await InAppUpdate.completeFlexibleUpdate();
                    },
                    child: const Text('Install Now'),
                  ),
                ],
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Error checking for update: $e");
      // No action needed; UpgradeAlert in main.dart handles fallback
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
