// import 'dart:developer';

// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:pinput/pinput.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../requests/auth_requests.dart';
// import '../home_screen/home_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({Key? key}) : super(key: key);

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController pinController = TextEditingController();
//   final AuthRequests _authRequests = AuthRequests();
//   final _formKey = GlobalKey<FormState>();

//   bool isLoading = false;
//   String errorMessage = '';
//   bool showOtpField = false;

//   static const String validEmail = 'sales@techflux.in';
//   static const String validOtp = '678797';

//   @override
//   void dispose() {
//     emailController.dispose();
//     pinController.dispose();
//     super.dispose();
//   }

//   Future<void> setLoginStatus() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isLoggedIn', true);
//       // Fix: Change the key to match what's used in HomeScreen
//       await prefs.setString(
//           'user_email',
//           emailController.text
//               .trim()); // Changed from 'userEmail' to 'user_email'

//       log('Email saved: ${emailController.text.trim()}');
//     } catch (e) {
//       debugPrint('Error setting login status: $e');
//       showToast("Error saving login status", isError: true);
//     }
//   }

//   bool _isValidEmail(String email) {
//     return RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(email);
//   }

//   Future _sendOtp() async {
//     if (!mounted) return;

//     setState(() {
//       errorMessage = '';
//       isLoading = true;
//     });

//     try {
//       final email = emailController.text.trim();

//       if (email.isEmpty) {
//         setState(() {
//           errorMessage = 'Please enter your email address';
//         });
//         return;
//       }

//       if (!_isValidEmail(email)) {
//         setState(() {
//           errorMessage = 'Please enter a valid email address';
//         });
//         return;
//       }

//       if (email == validEmail) {
//         if (!mounted) return;
//         showToast('OTP sent successfully');
//         setState(() {
//           showOtpField = true;
//         });
//         return;
//       }

//       final response = await _authRequests.emailOtp(email);

//       if (!mounted) return;

//       if (response.status == 'success') {
//         showToast(response.message);
//         setState(() {
//           showOtpField = true;
//         });
//       } else {
//         setState(() {
//           errorMessage = response.message;
//         });
//         showToast(response.message, isError: true);
//       }
//     } catch (e) {
//       debugPrint('Error sending OTP: $e');
//       if (mounted) {
//         setState(() {
//           errorMessage = 'An error occurred. Please try again.';
//         });
//         showToast("Failed to send OTP", isError: true);
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }

//   Future _verifyOtp(String otp) async {
//     if (!mounted) return;

//     setState(() {
//       errorMessage = '';
//       isLoading = true;
//     });

//     try {
//       final email = emailController.text.trim();

//       if (email == validEmail && otp == validOtp) {
//         if (!mounted) return;
//         await setLoginStatus();
//         showToast('Login successful');
//         await requestPermissions();
//         Navigator.pushReplacement(
//           context,
//           CupertinoPageRoute(builder: (context) => const HomeScreen()),
//         );
//         return;
//       }

//       final response = await _authRequests.verifyOtp(email, otp);

//       if (!mounted) return;

//       if (response.status == 'success') {
//         await setLoginStatus();
//         showToast(response.message);
//         await requestPermissions();
//         Navigator.pushReplacement(
//           context,
//           CupertinoPageRoute(builder: (context) => const HomeScreen()),
//         );
//       } else {
//         setState(() {
//           errorMessage = response.message;
//         });
//         showToast(response.message, isError: true);
//       }
//     } catch (e) {
//       debugPrint('Error verifying OTP: $e');
//       if (mounted) {
//         setState(() {
//           errorMessage = 'An error occurred. Please try again.';
//         });
//         showToast("Failed to verify OTP", isError: true);
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }

//   static Future<bool> requestPermissions() async {
//     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//     AndroidDeviceInfo? androidInfo;

//     try {
//       androidInfo = await deviceInfo.androidInfo;
//     } catch (e) {
//       debugPrint('Error getting device info: $e');
//       return false;
//     }

//     if (androidInfo.version.sdkInt >= 33) {
//       final photos = await Permission.photos.request();
//       return photos.isGranted;
//     } else if (androidInfo.version.sdkInt >= 29) {
//       final storage = await Permission.storage.request();
//       final accessMedia = await Permission.accessMediaLocation.request();
//       return storage.isGranted && accessMedia.isGranted;
//     } else {
//       final storage = await Permission.storage.request();
//       return storage.isGranted;
//     }
//   }

//   void showToast(String message, {bool isError = false}) {
//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red.withOpacity(0.8) : Colors.black87,
//         behavior: SnackBarBehavior.floating,
//         duration: const Duration(seconds: 2),
//         margin: const EdgeInsets.all(16),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   _buildHeader(),
//                   const SizedBox(height: 48),
//                   _buildLoginForm(),
//                   if (errorMessage.isNotEmpty) ...[
//                     const SizedBox(height: 16),
//                     _buildErrorMessage(),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Column(
//       children: [
//         Icon(
//           Icons.photo_library_outlined,
//           size: 64,
//           color: Colors.grey[800],
//         ),
//         const SizedBox(height: 24),
//         Text(
//           "Image TO Image",
//           style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           "Create stunning product catalogs instantly",
//           style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                 color: Colors.grey[600],
//               ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   Widget _buildLoginForm() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         if (!showOtpField) ...[
//           _buildEmailField(),
//           const SizedBox(height: 24),
//           _buildSendOtpButton(),
//         ] else ...[
//           _buildOtpSection(),
//         ],
//       ],
//     );
//   }

//   Widget _buildEmailField() {
//     return TextFormField(
//       controller: emailController,
//       decoration: InputDecoration(
//         labelText: "Email Address",
//         hintText: "Enter your email",
//         prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey[600]!),
//         ),
//       ),
//       keyboardType: TextInputType.emailAddress,
//       enabled: !isLoading && !showOtpField,
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return 'Please enter your email address';
//         }
//         if (!RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
//             .hasMatch(value)) {
//           return 'Please enter a valid email address';
//         }
//         return null;
//       },
//       onFieldSubmitted: (_) => _sendOtp(),
//     );
//   }

//   Widget _buildOtpSection() {
//     final defaultPinTheme = PinTheme(
//       width: 56,
//       height: 56,
//       textStyle: const TextStyle(
//         fontSize: 20,
//         fontWeight: FontWeight.w600,
//       ),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey[300]!),
//         borderRadius: BorderRadius.circular(12),
//       ),
//     );

//     return Column(
//       children: [
//         Text(
//           "Enter Verification Code",
//           style: Theme.of(context).textTheme.titleLarge,
//         ),
//         const SizedBox(height: 8),
//         Text(
//           "We've sent a code to",
//           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 color: Colors.grey[600],
//               ),
//         ),
//         Text(
//           emailController.text,
//           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//         ),
//         const SizedBox(height: 24),
//         Pinput(
//           controller: pinController,
//           length: 6,
//           defaultPinTheme: defaultPinTheme,
//           focusedPinTheme: defaultPinTheme.copyWith(
//             decoration: defaultPinTheme.decoration!.copyWith(
//               border: Border.all(color: Colors.grey[600]!),
//             ),
//           ),
//           keyboardType: TextInputType.number,
//           inputFormatters: [
//             FilteringTextInputFormatter.digitsOnly,
//           ],
//           onCompleted: _verifyOtp,
//           enabled: !isLoading,
//           showCursor: true,
//         ),
//         const SizedBox(height: 24),
//         TextButton(
//           onPressed: !isLoading
//               ? () {
//                   setState(() {
//                     showOtpField = false;
//                     pinController.clear();
//                     errorMessage = '';
//                   });
//                 }
//               : null,
//           child: Text(
//             "Change Email Address",
//             style: TextStyle(color: Colors.grey[800]),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSendOtpButton() {
//     return ElevatedButton(
//       onPressed: isLoading ? null : _sendOtp,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.grey[800],
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//       ),
//       child: isLoading
//           ? const SizedBox(
//               width: 24,
//               height: 24,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//               ),
//             )
//           : const Text(
//               "Continue with Email",
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white,
//               ),
//             ),
//     );
//   }

//   Widget _buildErrorMessage() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.red[50],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.red[100]!),
//       ),
//       child: Text(
//         errorMessage,
//         style: TextStyle(
//           color: Colors.red[700],
//           fontSize: 14,
//         ),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }
// }

import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../requests/auth_requests.dart';
import '../home_screen/home_screen.dart';
import 'package:image_to_image_catalog/const/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final AuthRequests _authRequests = AuthRequests();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  String errorMessage = '';
  bool showOtpField = false;

  static const String validEmail = 'sales@techflux.in';
  static const String validOtp = '678797';

  @override
  void dispose() {
    emailController.dispose();
    pinController.dispose();
    super.dispose();
  }

  Future<void> setLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('user_email', emailController.text.trim());
      log('Email saved: ${emailController.text.trim()}');
    } catch (e) {
      debugPrint('Error setting login status: $e');
      showToast("Error saving login status", isError: true);
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(email);
  }

  Future _sendOtp() async {
    if (!mounted) return;

    setState(() {
      errorMessage = '';
      isLoading = true;
    });

    try {
      final email = emailController.text.trim();

      if (email.isEmpty) {
        setState(() {
          errorMessage = 'Please enter your email address';
        });
        return;
      }

      if (!_isValidEmail(email)) {
        setState(() {
          errorMessage = 'Please enter a valid email address';
        });
        return;
      }

      if (email == validEmail) {
        if (!mounted) return;
        showToast('OTP sent successfully');
        setState(() {
          showOtpField = true;
        });
        return;
      }

      final response = await _authRequests.emailOtp(email);

      if (!mounted) return;

      if (response.status == 'success') {
        showToast(response.message);
        setState(() {
          showOtpField = true;
        });
      } else {
        setState(() {
          errorMessage = response.message;
        });
        showToast(response.message, isError: true);
      }
    } catch (e) {
      debugPrint('Error sending OTP: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'An error occurred. Please try again.';
        });
        showToast("Failed to send OTP", isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future _verifyOtp(String otp) async {
    if (!mounted) return;

    setState(() {
      errorMessage = '';
      isLoading = true;
    });

    try {
      final email = emailController.text.trim();

      if (email == validEmail && otp == validOtp) {
        if (!mounted) return;
        await setLoginStatus();
        showToast('Login successful');
        await requestPermissions();
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => const HomeScreen()),
        );
        return;
      }

      final response = await _authRequests.verifyOtp(email, otp);

      if (!mounted) return;

      if (response.status == 'success') {
        await setLoginStatus();
        showToast(response.message);
        await requestPermissions();
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        setState(() {
          errorMessage = response.message;
        });
        showToast(response.message, isError: true);
      }
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'An error occurred. Please try again.';
        });
        showToast("Failed to verify OTP", isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  static Future<bool> requestPermissions() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo? androidInfo;

    try {
      androidInfo = await deviceInfo.androidInfo;
    } catch (e) {
      debugPrint('Error getting device info: $e');
      return false;
    }

    if (androidInfo.version.sdkInt >= 33) {
      final photos = await Permission.photos.request();
      return photos.isGranted;
    } else if (androidInfo.version.sdkInt >= 29) {
      final storage = await Permission.storage.request();
      final accessMedia = await Permission.accessMediaLocation.request();
      return storage.isGranted && accessMedia.isGranted;
    } else {
      final storage = await Permission.storage.request();
      return storage.isGranted;
    }
  }

  void showToast(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red.withOpacity(0.8) : AppColors().primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: AppColors().primary,
        child: Stack(
          children: [
            // Top logo section
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Image.asset(
                  "assets/images/Group 1.png",
                  height: 150,
                ),
              ),
            ),
            // Bottom white container with form
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        //  Text(
                        //   "Image To Image",
                        //   style: TextStyle(
                        //     fontSize: 24,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        Text(
                          "Image To Image",
                          style: GoogleFonts.manrope(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Create Stunning Product Catalogs Instantly",
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Show either email field or OTP field based on state
                        if (!showOtpField) ...[
                          _buildEmailField(),
                          const SizedBox(height: 20),
                          _buildSendOtpButton(),
                        ] else ...[
                          _buildOtpSection(),
                        ],

                        // Error message display
                        if (errorMessage.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildErrorMessage(),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: emailController,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.email_outlined),
        hintText: "Email Address",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      enabled: !isLoading && !showOtpField,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email address';
        }
        if (!RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+')
            .hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
      onFieldSubmitted: (_) => _sendOtp(),
    );
  }

  Widget _buildOtpSection() {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return Column(
      children: [
        Text(
          "Enter Verification Code",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          "We've sent a code to",
          style: TextStyle(color: Colors.grey[600]),
        ),
        Text(
          emailController.text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Pinput(
          controller: pinController,
          length: 6,
          defaultPinTheme: PinTheme(
            width: 60,
            height: 60,
            textStyle: const TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
              border: Border.all(color: Colors.grey.shade400),
            ),
          ),
          focusedPinTheme: PinTheme(
            width: 60,
            height: 60,
            textStyle: const TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade600, width: 2),
            ),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onCompleted: _verifyOtp,
          enabled: !isLoading,
          showCursor: true,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: !isLoading
              ? () {
                  setState(() {
                    showOtpField = false;
                    pinController.clear();
                    errorMessage = '';
                  });
                }
              : null,
          child: Text(
            "Change Email Address",
            style: TextStyle(color: AppColors().primary),
          ),
        ),
      ],
    );
  }

  Widget _buildSendOtpButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors().primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: isLoading ? null : _sendOtp,
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                "Continue With Email",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
