// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:upgrader/upgrader.dart';

// import 'const/app_colors.dart';
// import 'screens/splash_screeen/splash_screen.dart';

// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback =
//           (X509Certificate cert, String host, int port) => true;
//   }
// }

// void main() {
//   HttpOverrides.global = MyHttpOverrides();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return UpgradeAlert(
//       barrierDismissible: false,
//       upgrader: Upgrader(
//         storeController: UpgraderStoreController(
//           onAndroid: () => UpgraderPlayStore(),
//           oniOS: () => UpgraderAppStore(),
//         ),
//       ),
//       child: MaterialApp(
//         title: 'Image To Image Catalog',
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           colorScheme: ColorScheme.fromSeed(seedColor: AppColors().primary),
//           // textTheme: GoogleFonts.manropeTextTheme(),
//           scaffoldBackgroundColor: Colors.white,
//           useMaterial3: true,
//         ),
//         home: SplashScreen(),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';
import 'const/app_colors.dart';
import 'screens/splash_screeen/splash_screen.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      barrierDismissible: false,
      upgrader: Upgrader(
        storeController: UpgraderStoreController(
          onAndroid: () => UpgraderPlayStore(),
          oniOS: () => UpgraderAppStore(),
        ),
        durationUntilAlertAgain: Duration.zero,
      ),
      child: MaterialApp(
        title: 'Image To Image Catalog',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors().primary),
          scaffoldBackgroundColor: Colors.white,
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
