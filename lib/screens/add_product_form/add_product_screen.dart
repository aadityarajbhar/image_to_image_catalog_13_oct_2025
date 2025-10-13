// import 'dart:async';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:io';
// import '../../database/database_helper.dart';
// import '../../helper/ad_helper.dart';
// import '../../models/product_model.dart';
// import '../auth_screens/login_screens.dart';
// import '../login_screen/login_screen.dart';

// class AddProductScreen extends StatefulWidget {
//   const AddProductScreen({Key? key}) : super(key: key);

//   @override
//   State<AddProductScreen> createState() => _AddProductScreenState();
// }

// class _AddProductScreenState extends State<AddProductScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _priceController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   File? _image;
//   InterstitialAd? _interstitialAd;
//   bool _isLoading = false;
//   bool _hasReachedLimit = false;
//   static const int _maxProducts = 50;
//   String? userEmail;

//   @override
//   void initState() {
//     super.initState();
//     print('AddProductScreen initialized');
//     _initializeScreen();
//   }

//   @override
//   void dispose() {
//     _interstitialAd?.dispose();
//     _priceController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeScreen() async {
//     try {
//       final isLoggedIn = await _checkUserEmail();
//       if (isLoggedIn && mounted) {
//         await _checkProductCount();
//         _createInterstitialAd();
//       }
//     } catch (e) {
//       debugPrint('Error in initialization: $e');
//     }
//   }

//   Future<void> _checkProductCount() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final email = prefs.getString('user_email') ?? '';
//       final products =
//           await DatabaseHelper.instance.getAllProductsForUser(email);

//       if (products.length >= _maxProducts) {
//         setState(() {
//           _hasReachedLimit = true;
//         });
//         if (mounted) {
//           showAnimatedToast('Maximum product limit (50) reached!');
//           Future.delayed(const Duration(seconds: 2), () {
//             if (mounted) {
//               Navigator.pop(context);
//             }
//           });
//         }
//       }
//     } catch (e) {
//       debugPrint('Error checking product count: $e');
//       if (mounted) {
//         showAnimatedToast('Error checking product count');
//       }
//     }
//   }

//   Future<bool> _checkUserEmail() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final email = prefs.getString('user_email');
//       print('Retrieved email from SharedPreferences: $email');

//       if (email == null || email.isEmpty) {
//         print('No email found in SharedPreferences');
//         if (mounted) {
//           showAnimatedToast('Please login first');
//           await Future.delayed(const Duration(seconds: 2));
//           if (mounted) {
//             Navigator.of(context).pushReplacement(
//                 CupertinoPageRoute(builder: (context) => const LoginScreen()));
//           }
//         }
//         return false;
//       }

//       setState(() {
//         userEmail = email;
//       });
//       print('Email set in state: $userEmail');
//       return true;
//     } catch (e) {
//       print('Error getting user email: $e');
//       if (mounted) {
//         showAnimatedToast('Error retrieving user data');
//       }
//       return false;
//     }
//   }

//   void _createInterstitialAd() {
//     const timeout = Duration(seconds: 5);
//     Timer? timeoutTimer;

//     timeoutTimer = Timer(timeout, () {
//       debugPrint('Ad load timeout');
//       _interstitialAd = null;
//       _createInterstitialAd();
//     });

//     InterstitialAd.load(
//       adUnitId: AdHelper.getInterstitalAdUnitId,
//       request: const AdRequest(),
//       adLoadCallback: InterstitialAdLoadCallback(
//         onAdLoaded: (InterstitialAd ad) {
//           timeoutTimer?.cancel();
//           _interstitialAd = ad;
//           _interstitialAd!.setImmersiveMode(true);
//         },
//         onAdFailedToLoad: (LoadAdError error) {
//           timeoutTimer?.cancel();
//           debugPrint('InterstitialAd failed to load: $error');
//           _interstitialAd = null;
//           Future.delayed(const Duration(seconds: 2), _createInterstitialAd);
//         },
//       ),
//     );
//   }

//   Future<void> _showInterstitialAd() async {
//     if (_interstitialAd == null) {
//       debugPrint('Warning: attempt to show interstitial before loaded.');
//       if (mounted) {
//         Navigator.pop(context, true);
//       }
//       return;
//     }

//     _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
//       onAdDismissedFullScreenContent: (InterstitialAd ad) {
//         ad.dispose();
//         Navigator.pop(context, true);
//       },
//       onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
//         debugPrint('$ad failed to show with error $error');
//         ad.dispose();
//         if (mounted) {
//           showAnimatedToast('Failed to show advertisement');
//           Navigator.pop(context, true);
//         }
//       },
//       onAdShowedFullScreenContent: (InterstitialAd ad) {
//         debugPrint('$ad showed fullscreen content.');
//       },
//     );

//     await _interstitialAd!.show();
//     _interstitialAd = null;
//   }

//   Future<void> _addProduct() async {
//     log('Add product started');

//     if (_isLoading || _hasReachedLimit) {
//       log('Cannot proceed: loading or limit reached');
//       return;
//     }

//     if (userEmail == null || userEmail!.isEmpty) {
//       log('No user email found');
//       final isLoggedIn = await _checkUserEmail();
//       if (!isLoggedIn) return;
//     }

//     // Recheck product count before adding
//     await _checkProductCount();
//     if (_hasReachedLimit) {
//       log('Product limit reached during add attempt');
//       return;
//     }

//     if (!_formKey.currentState!.validate()) {
//       log('Form validation failed');
//       return;
//     }

//     // Add image validation
//     if (_image == null) {
//       log('No image selected');
//       showAnimatedToast('Please select an image for the product');
//       return;
//     }

//     try {
//       setState(() => _isLoading = true);
//       log('Loading state set to true');

//       if (_descriptionController.text.isEmpty ||
//           _priceController.text.isEmpty) {
//         log('Empty fields detected');
//         showAnimatedToast('Please fill in all fields');
//         return;
//       }

//       // Validate image size
//       final imageFile = await _image!.length();
//       if (imageFile > 5 * 1024 * 1024) {
//         // 5MB limit
//         showAnimatedToast('Image size should be less than 5MB');
//         setState(() => _isLoading = false);
//         return;
//       }

//       final product = Product(
//         description: _descriptionController.text,
//         price: double.parse(_priceController.text),
//         image: _image?.path,
//       );
//       log('Product created: ${product.description}, ${product.price}');

//       final id =
//           await DatabaseHelper.instance.insertProduct(product, userEmail!);
//       log('Product inserted successfully with id: $id');

//       if (mounted) {
//         showAnimatedToast('Product Added Successfully');
//         await _showInterstitialAd();
//       }
//     } catch (e) {
//       log('Error in _addProduct: $e');
//       if (mounted) {
//         showAnimatedToast('Error saving product: $e');
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   Future<void> _pickImage() async {
//     try {
//       final picker = ImagePicker();
//       final pickedFile = await picker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 1200, // Limit image dimensions
//         maxHeight: 1200,
//         imageQuality: 85, // Compress image quality
//       );

//       if (pickedFile != null) {
//         // Validate file type
//         final extension = pickedFile.path.split('.').last.toLowerCase();
//         if (!['jpg', 'jpeg', 'png'].contains(extension)) {
//           if (mounted) {
//             showAnimatedToast('Please select a JPG or PNG image');
//           }
//           return;
//         }

//         final appDir = await getApplicationDocumentsDirectory();
//         final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
//         final localImage = File('${appDir.path}/$fileName');

//         await File(pickedFile.path).copy(localImage.path);

//         setState(() {
//           _image = localImage;
//         });
//         if (mounted) {
//           showAnimatedToast('Image selected successfully');
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         showAnimatedToast('Error picking image: $e');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.red.shade300,
//         title: const Text(
//           'Add New Product',
//           style: TextStyle(color: Colors.white),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Center(
//                 child: Text(
//                   '(You Can Add Maximum 50 Products)',
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//               if (_hasReachedLimit)
//                 Padding(
//                   padding: EdgeInsets.only(top: 8.h),
//                   child: Text(
//                     'Product limit reached. Please delete some products first.',
//                     style: TextStyle(
//                       color: Colors.red,
//                       fontSize: 14.sp,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               SizedBox(height: 16.h),
//               GestureDetector(
//                 onTap: _hasReachedLimit ? null : _pickImage,
//                 child: Container(
//                   height: 200.h,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[200],
//                     border: Border.all(color: Colors.grey),
//                     borderRadius: BorderRadius.circular(8.r),
//                   ),
//                   child: _image != null
//                       ? ClipRRect(
//                           borderRadius: BorderRadius.circular(8.r),
//                           child: Image.file(_image!, fit: BoxFit.fitHeight),
//                         )
//                       : Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.add_photo_alternate,
//                                 size: 50.sp, color: Colors.grey),
//                             SizedBox(height: 8.h),
//                             Text(
//                               'Tap to add image',
//                               style: TextStyle(
//                                 color: Colors.grey[600],
//                                 fontSize: 14.sp,
//                               ),
//                             ),
//                           ],
//                         ),
//                 ),
//               ),
//               SizedBox(height: 16.h),
//               TextFormField(
//                 controller: _descriptionController,
//                 enabled: !_hasReachedLimit,
//                 decoration: InputDecoration(
//                   labelText: 'name',
//                   border: const OutlineInputBorder(),
//                   filled: true,
//                   fillColor: Colors.grey[50],
//                 ),
//                 validator: (value) {
//                   if (value?.isEmpty ?? true) return 'Please enter Name';
//                   // if (value!.length < 5) {
//                   //   return 'Description must be at least 5 characters';
//                   // }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 16.h),
//               TextFormField(
//                 controller: _priceController,
//                 enabled: !_hasReachedLimit,
//                 decoration: InputDecoration(
//                   labelText: 'Price',
//                   border: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.red.shade300),
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.red.shade300),
//                   ),
//                   prefixText: 'Rs. ',
//                   filled: true,
//                   fillColor: Colors.grey[50],
//                 ),
//                 keyboardType:
//                     const TextInputType.numberWithOptions(decimal: true),
//                 validator: (value) {
//                   if (value?.isEmpty ?? true) return 'Please enter price';
//                   final price = double.tryParse(value!);
//                   if (price == null) return 'Please enter a valid price';
//                   if (price <= 0) return 'Price must be greater than 0';
//                   return null;
//                 },
//               ),
//               SizedBox(height: 24.h),
//               ElevatedButton(
//                 onPressed:
//                     (_isLoading || _hasReachedLimit) ? null : _addProduct,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red.shade300,
//                   padding: EdgeInsets.symmetric(vertical: 16.h),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8.r),
//                   ),
//                 ),
//                 child: _isLoading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : Text(
//                         'Add Product',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18.sp,
//                         ),
//                       ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void showAnimatedToast(String message) {
//     if (!mounted) return;

//     final overlay = Overlay.of(context);
//     final overlayEntry = OverlayEntry(
//       builder: (context) {
//         // Get the keyboard height
//         final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
//         // Calculate bottom padding based on keyboard visibility
//         final bottomPadding = keyboardHeight > 0 ? keyboardHeight + 10.h : 50.h;

//         return Positioned(
//           // Position toast above keyboard when it's visible
//           bottom: bottomPadding,
//           left: 20.w,
//           right: 20.w,
//           child: Material(
//             color: Colors.transparent,
//             child: TweenAnimationBuilder<double>(
//               tween: Tween(begin: 0.0, end: 1.0),
//               duration: const Duration(milliseconds: 500),
//               builder: (context, value, child) {
//                 return Transform.translate(
//                   offset: Offset(0, (1 - value) * 50),
//                   child: Opacity(
//                     opacity: value,
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                           horizontal: 24.w, vertical: 12.h),
//                       decoration: BoxDecoration(
//                         color: Colors.black87,
//                         borderRadius: BorderRadius.circular(25.r),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black26,
//                             blurRadius: 8,
//                             offset: const Offset(0, 3),
//                           ),
//                         ],
//                       ),
//                       child: Text(
//                         message,
//                         style: TextStyle(color: Colors.white, fontSize: 16.sp),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         );
//       },
//     );

//     overlay.insert(overlayEntry);
//     Future.delayed(const Duration(seconds: 2), () {
//       if (overlayEntry.mounted) {
//         overlayEntry.remove();
//       }
//     });
//   }
// }

import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../database/database_helper.dart';
import '../../helper/ad_helper.dart';
import '../../models/product_model.dart';
import '../login_screen/login_screen.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _image;
  InterstitialAd? _interstitialAd;
  bool _isLoading = false;
  bool _hasReachedLimit = false;
  static const int _maxProducts = 50;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    print('AddProductScreen initialized');
    _initializeScreen();
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _initializeScreen() async {
    try {
      final isLoggedIn = await _checkUserEmail();
      if (isLoggedIn && mounted) {
        await _checkProductCount();
        _createInterstitialAd();
      }
    } catch (e) {
      debugPrint('Error in initialization: $e');
    }
  }

  Future<void> _checkProductCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email') ?? '';
      final products =
          await DatabaseHelper.instance.getAllProductsForUser(email);

      if (products.length >= _maxProducts) {
        setState(() {
          _hasReachedLimit = true;
        });
        if (mounted) {
          showAnimatedToast('Maximum product limit (50) reached!');
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error checking product count: $e');
      if (mounted) {
        showAnimatedToast('Error checking product count');
      }
    }
  }

  Future<bool> _checkUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email');
      print('Retrieved email from SharedPreferences: $email');

      if (email == null || email.isEmpty) {
        print('No email found in SharedPreferences');
        if (mounted) {
          showAnimatedToast('Please login first');
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            Navigator.of(context).pushReplacement(
                CupertinoPageRoute(builder: (context) => const LoginScreen()));
          }
        }
        return false;
      }

      setState(() {
        userEmail = email;
      });
      print('Email set in state: $userEmail');
      return true;
    } catch (e) {
      print('Error getting user email: $e');
      if (mounted) {
        showAnimatedToast('Error retrieving user data');
      }
      return false;
    }
  }

  void _createInterstitialAd() {
    const timeout = Duration(seconds: 5);
    Timer? timeoutTimer;

    timeoutTimer = Timer(timeout, () {
      debugPrint('Ad load timeout');
      _interstitialAd = null;
      _createInterstitialAd();
    });

    InterstitialAd.load(
      adUnitId: AdHelper.getInterstitalAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          timeoutTimer?.cancel();
          _interstitialAd = ad;
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          timeoutTimer?.cancel();
          debugPrint('InterstitialAd failed to load: $error');
          _interstitialAd = null;
          Future.delayed(const Duration(seconds: 2), _createInterstitialAd);
        },
      ),
    );
  }

  Future<void> _showInterstitialAd() async {
    if (_interstitialAd == null) {
      debugPrint('Warning: attempt to show interstitial before loaded.');
      if (mounted) {
        Navigator.pop(context, true);
      }
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        Navigator.pop(context, true);
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('$ad failed to show with error $error');
        ad.dispose();
        if (mounted) {
          showAnimatedToast('Failed to show advertisement');
          Navigator.pop(context, true);
        }
      },
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        debugPrint('$ad showed fullscreen content.');
      },
    );

    await _interstitialAd!.show();
    _interstitialAd = null;
  }

  Future<void> _addProduct() async {
    log('Add product started');

    if (_isLoading || _hasReachedLimit) {
      log('Cannot proceed: loading or limit reached');
      return;
    }

    if (userEmail == null || userEmail!.isEmpty) {
      log('No user email found');
      final isLoggedIn = await _checkUserEmail();
      if (!isLoggedIn) return;
    }

    await _checkProductCount();
    if (_hasReachedLimit) {
      log('Product limit reached during add attempt');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      log('Form validation failed');
      return;
    }

    if (_image == null) {
      log('No image selected');
      showAnimatedToast('Please select an image for the product');
      return;
    }

    try {
      setState(() => _isLoading = true);
      log('Loading state set to true');

      if (_descriptionController.text.isEmpty ||
          _priceController.text.isEmpty) {
        log('Empty fields detected');
        showAnimatedToast('Please fill in all fields');
        return;
      }

      final imageFile = await _image!.length();
      if (imageFile > 5 * 1024 * 1024) {
        showAnimatedToast('Image size should be less than 5MB');
        setState(() => _isLoading = false);
        return;
      }

      final product = Product(
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        image: _image?.path,
      );
      log('Product created: ${product.description}, ${product.price}');

      final id =
          await DatabaseHelper.instance.insertProduct(product, userEmail!);
      log('Product inserted successfully with id: $id');

      if (mounted) {
        showAnimatedToast('Product Added Successfully');
        await _showInterstitialAd();
      }
    } catch (e) {
      log('Error in _addProduct: $e');
      if (mounted) {
        showAnimatedToast('Error saving product: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final extension = pickedFile.path.split('.').last.toLowerCase();
        if (!['jpg', 'jpeg', 'png'].contains(extension)) {
          if (mounted) {
            showAnimatedToast('Please select a JPG or PNG image');
          }
          return;
        }

        final appDir = await getApplicationDocumentsDirectory();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
        final localImage = File('${appDir.path}/$fileName');

        await File(pickedFile.path).copy(localImage.path);

        setState(() {
          _image = localImage;
        });
        if (mounted) {
          showAnimatedToast('Image selected successfully');
        }
      }
    } catch (e) {
      if (mounted) {
        showAnimatedToast('Error picking image: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade300,
        title: const Text(
          'Add New Product',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  '(You Can Add Maximum 50 Products)',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              if (_hasReachedLimit)
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.01),
                  child: Text(
                    'Product limit reached. Please delete some products first.',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(height: screenHeight * 0.02),
              GestureDetector(
                onTap: _hasReachedLimit ? null : _pickImage,
                child: Container(
                  height: screenHeight * 0.25,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_image!, fit: BoxFit.fitHeight),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate,
                                size: screenWidth * 0.125, color: Colors.grey),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              'Tap to add image',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: screenWidth * 0.035,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              TextFormField(
                controller: _descriptionController,
                enabled: !_hasReachedLimit,
                decoration: InputDecoration(
                  labelText: 'name',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter Name';
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.02),
              TextFormField(
                controller: _priceController,
                enabled: !_hasReachedLimit,
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red.shade300),
                  ),
                  prefixText: 'Rs. ',
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter price';
                  final price = double.tryParse(value!);
                  if (price == null) return 'Please enter a valid price';
                  if (price <= 0) return 'Price must be greater than 0';
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.03),
              ElevatedButton(
                onPressed:
                    (_isLoading || _hasReachedLimit) ? null : _addProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade300,
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Add Product',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.045,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showAnimatedToast(String message) {
    if (!mounted) return;

    final overlay = Overlay.of(context);
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    final overlayEntry = OverlayEntry(
      builder: (context) {
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        final bottomPadding = keyboardHeight > 0
            ? keyboardHeight + screenHeight * 0.0125
            : screenHeight * 0.0625;

        return Positioned(
          bottom: bottomPadding,
          left: screenWidth * 0.05,
          right: screenWidth * 0.05,
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, (1 - value) * 50),
                  child: Opacity(
                    opacity: value,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.06,
                        vertical: screenHeight * 0.015,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        message,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.04,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}
