// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'dart:io';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:open_file/open_file.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:developer' as dev;
// import '../../database/database_helper.dart';
// import '../../helper/ad_helper.dart';
// import '../../models/product_model.dart';
// import '../login_screen/login_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   List<Product> products = [];
//   bool isLoading = true;
//   String? errorMessage;
//   RewardedAd? _rewardedAd;
//   BannerAd? _bannerAd;
//   bool _isAdLoaded = false;
//   String? lastDownloadedPdfPath;
//   String? userEmail;
//   bool _isInitialized = false;

//   @override
//   void initState() {
//     super.initState();
//     _initialize();
//   }

//   Future<void> _initialize() async {
//     try {
//       await _getUserEmail();
//       if (userEmail != null) {
//         await _loadProducts();
//       }
//       _initializeAds();
//       setState(() {
//         _isInitialized = true;
//         isLoading = false;
//       });
//     } catch (e) {
//       dev.log('Initialization error: $e');
//       setState(() {
//         errorMessage = 'Failed to initialize app';
//         isLoading = false;
//       });
//     }
//   }

//   void _initializeAds() {
//     _initBannerAd();
//     _createRewardedAd();
//   }

//   Future<void> _deleteProduct(Product product) async {
//     try {
//       // Show confirmation dialog
//       bool? confirmDelete = await showDialog<bool>(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             shape: RoundedRectangleBorder(),
//             backgroundColor: Colors.white,
//             title: const Text('Confirm Delete'),
//             content:
//                 const Text('Are you sure you want to delete this product?'),
//             actions: [
//               TextButton(
//                 child: const Text('Cancel'),
//                 onPressed: () => Navigator.of(context).pop(false),
//               ),
//               TextButton(
//                 child: Text(
//                   'Delete',
//                   style: TextStyle(color: Colors.red.shade300),
//                 ),
//                 onPressed: () => Navigator.of(context).pop(true),
//               ),
//             ],
//           );
//         },
//       );

//       if (confirmDelete == true) {
//         // Show loading indicator
//         setState(() {
//           isLoading = true;
//         });

//         // Delete the product from database
//         final result = await DatabaseHelper.instance.deleteProduct(
//           product.id!,
//           userEmail!,
//         );

//         if (result > 0) {
//           // If product has an image, delete it from storage
//           if (product.image != null && product.image!.isNotEmpty) {
//             final file = File(product.image!);
//             if (await file.exists()) {
//               await file.delete();
//             }
//           }

//           // Update the UI
//           setState(() {
//             products.removeWhere((p) => p.id == product.id);
//             isLoading = false;
//           });

//           // Show success message
//           if (mounted) {
//             showAnimatedToast('Product deleted successfully');
//           }
//         } else {
//           if (mounted) {
//             showAnimatedToast('Failed to delete product');
//           }
//         }
//       }
//     } catch (e) {
//       print('Error deleting product: $e');
//       if (mounted) {
//         showAnimatedToast('Error deleting product');
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }

//   void _initBannerAd() {
//     try {
//       _bannerAd = BannerAd(
//         adUnitId: AdHelper.bannerAdUnitId,
//         size: AdSize.banner,
//         request: const AdRequest(),
//         listener: BannerAdListener(
//           onAdLoaded: (ad) {
//             dev.log('Banner ad loaded');
//             if (mounted) {
//               setState(() {
//                 _isAdLoaded = true;
//               });
//             }
//           },
//           onAdFailedToLoad: (ad, error) {
//             dev.log('Banner ad failed: ${error.message}');
//             ad.dispose();
//             if (mounted) {
//               setState(() {
//                 _isAdLoaded = false;
//               });
//             }
//             // Retry loading banner ad after delay
//             Future.delayed(const Duration(seconds: 30), _initBannerAd);
//           },
//         ),
//       );
//       _bannerAd?.load();
//     } catch (e) {
//       dev.log('Banner ad initialization error: $e');
//     }
//   }

//   Future<void> _getUserEmail() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final email = prefs.getString('user_email');

//       if (email == null || email.isEmpty) {
//         if (mounted) {
//           Navigator.of(context).pushReplacement(
//             CupertinoPageRoute(builder: (context) => const LoginScreen()),
//           );
//         }
//         return;
//       }

//       setState(() {
//         userEmail = email;
//       });
//     } catch (e) {
//       dev.log('Error getting email: $e');
//       throw Exception('Failed to get user email');
//     }
//   }

//   Future<void> _loadProducts() async {
//     if (!mounted) return;

//     try {
//       setState(() {
//         isLoading = true;
//         errorMessage = null;
//       });

//       if (userEmail == null) {
//         throw Exception('User email not available');
//       }

//       final db = await DatabaseHelper.instance.database;
//       final productsList =
//           await DatabaseHelper.instance.getAllProductsForUser(userEmail!);

//       if (mounted) {
//         setState(() {
//           products = productsList;
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       dev.log('Error loading products: $e');
//       if (mounted) {
//         setState(() {
//           errorMessage = 'Failed to load products';
//           isLoading = false;
//         });
//       }
//     }
//   }

//   void _createRewardedAd() {
//     try {
//       RewardedAd.load(
//         adUnitId: AdHelper.getRewardedAdUnitId,
//         request: const AdRequest(),
//         rewardedAdLoadCallback: RewardedAdLoadCallback(
//           onAdLoaded: (ad) {
//             _rewardedAd = ad;
//           },
//           onAdFailedToLoad: (error) {
//             dev.log('Rewarded ad failed: ${error.message}');
//             _rewardedAd = null;
//             Future.delayed(const Duration(seconds: 30), _createRewardedAd);
//           },
//         ),
//       );
//     } catch (e) {
//       dev.log('Rewarded ad creation error: $e');
//     }
//   }

//   void showAnimatedToast(String message) {
//     if (!mounted) return;

//     final overlay = Overlay.of(context);
//     final overlayEntry = OverlayEntry(
//       builder: (context) {
//         // Get the keyboard height
//         final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
//         // Calculate bottom padding based on keyboard visibility
//         final bottomPadding = keyboardHeight > 0 ? keyboardHeight + 10.0 : 50.0;

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

//   void _showRewardedAd() {
//     dev.log('Attempting to show Rewarded Ad');

//     if (_rewardedAd != null) {
//       _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
//         onAdShowedFullScreenContent: (RewardedAd ad) {
//           dev.log('Rewarded Ad showed full screen content');
//         },
//         onAdDismissedFullScreenContent: (RewardedAd ad) {
//           dev.log('Rewarded Ad was dismissed');
//           ad.dispose();
//           _createRewardedAd();
//         },
//         onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
//           dev.log('Rewarded Ad failed to show');
//           ad.dispose();
//           _createRewardedAd();
//           // Directly generate PDF instead of showing error toast
//           _generateAndDownloadPDF();
//         },
//       );

//       try {
//         _rewardedAd!.setImmersiveMode(true);
//         _rewardedAd!.show(
//           onUserEarnedReward: (_, RewardItem reward) {
//             _generateAndDownloadPDF();
//           },
//         );
//         _rewardedAd = null;
//       } catch (e) {
//         // On error, directly generate PDF instead of showing error toast
//         _generateAndDownloadPDF();
//       }
//     } else {
//       // If ad is not ready, directly generate PDF instead of showing toast
//       _generateAndDownloadPDF();
//       _createRewardedAd(); // Still create ad for next time
//     }
//   }

//   void _generateAndDownloadPDF() async {
//     if (products.isEmpty) {
//       showAnimatedToast('Cannot generate PDF: No products available');
//       return;
//     }
//     try {
//       final pdf = pw.Document();

//       // Convert screen util dimensions to PDF points
//       double pdfFontSize(double size) => size * (72 / 96);

//       // Function to create a product cell
//       pw.Widget buildProductCell(Product product) {
//         pw.Widget productImage;

//         // Handle image
//         if (product.image != null && product.image!.isNotEmpty) {
//           try {
//             final file = File(product.image!);
//             if (file.existsSync()) {
//               productImage = pw.Image(
//                 pw.MemoryImage(file.readAsBytesSync()),
//                 height: 120,
//                 width: 120,
//                 fit: pw.BoxFit.cover,
//               );
//             } else {
//               productImage = _buildNoImageContainer();
//             }
//           } catch (e) {
//             productImage = _buildNoImageContainer();
//           }
//         } else {
//           productImage = _buildNoImageContainer();
//         }

//         return pw.Container(
//           height: 200,
//           width: 160,
//           padding: const pw.EdgeInsets.all(8),
//           decoration: pw.BoxDecoration(
//             border: pw.Border.all(color: PdfColors.grey300),
//           ),
//           child: pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.center,
//             children: [
//               productImage,
//               pw.SizedBox(height: 8),
//               pw.Text(
//                 product.description,
//                 style: pw.TextStyle(
//                   fontSize: pdfFontSize(12),
//                   fontWeight: pw.FontWeight.bold,
//                 ),
//                 textAlign: pw.TextAlign.center,
//                 maxLines: 2,
//               ),
//               pw.SizedBox(height: 4),
//               pw.Text(
//                 'Rs. ${product.price.toStringAsFixed(2)}',
//                 style: pw.TextStyle(
//                   fontSize: pdfFontSize(12),
//                   color: PdfColors.red,
//                   fontWeight: pw.FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         );
//       }

//       pdf.addPage(
//         pw.MultiPage(
//           pageFormat: PdfPageFormat.a4,
//           margin: const pw.EdgeInsets.all(40),
//           header: (pw.Context context) {
//             return pw.Container(
//               padding: const pw.EdgeInsets.only(bottom: 20),
//               child: pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.center,
//                 children: [
//                   pw.Text(
//                     'Product Catalog',
//                     style: pw.TextStyle(
//                       fontSize: pdfFontSize(24),
//                       fontWeight: pw.FontWeight.bold,
//                     ),
//                   ),
//                   pw.SizedBox(height: 10),
//                   pw.Text(
//                     'Total Products: ${products.length}',
//                     style: pw.TextStyle(
//                       fontSize: pdfFontSize(14),
//                       color: PdfColors.grey700,
//                     ),
//                   ),
//                   pw.Divider(),
//                 ],
//               ),
//             );
//           },
//           build: (pw.Context context) {
//             List<pw.Widget> pages = [];

//             // Create rows with 3 products each
//             for (var i = 0; i < products.length; i += 3) {
//               final rowItems = <pw.Widget>[];

//               // Add up to 3 products in this row
//               for (var j = 0; j < 3 && (i + j) < products.length; j++) {
//                 rowItems.add(
//                   pw.Expanded(
//                     child: buildProductCell(products[i + j]),
//                   ),
//                 );

//                 // Add spacing between products
//                 if (j < 2 && (i + j + 1) < products.length) {
//                   rowItems.add(pw.SizedBox(width: 10));
//                 }
//               }

//               // Add the row to pages
//               pages.add(
//                 pw.Row(
//                   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                   children: rowItems,
//                 ),
//               );

//               // Add spacing between rows
//               if (i + 3 < products.length) {
//                 pages.add(pw.SizedBox(height: 20));
//               }
//             }

//             return pages;
//           },
//         ),
//       );

//       // Save PDF to downloads folder
//       final directory = Directory("/storage/emulated/0/Download");
//       if (!directory.existsSync()) {
//         directory.createSync(recursive: true);
//       }

//       final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
//       final file = File('${directory.path}/ProductCatalog_$timestamp.pdf');
//       final String fileName = 'ProductCatalog_$timestamp.pdf';
//       await file.writeAsBytes(await pdf.save());
//       final String filePath = '${directory.path}/$fileName';

//       if (mounted) {
//         setState(() {
//           lastDownloadedPdfPath = filePath;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('PDF Downloaded Successfully'),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 2),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to generate PDF: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   pw.Widget _buildNoImageContainer() {
//     return pw.Container(
//       height: 120,
//       width: 120,
//       decoration: pw.BoxDecoration(
//         color: PdfColors.grey200,
//         border: pw.Border.all(color: PdfColors.grey400),
//       ),
//       child: pw.Center(
//         child: pw.Text(
//           'No Image',
//           style: pw.TextStyle(
//             color: PdfColors.grey600,
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _openPDF() async {
//     if (lastDownloadedPdfPath != null) {
//       try {
//         final file = File(lastDownloadedPdfPath!);
//         if (await file.exists()) {
//           await OpenFile.open(lastDownloadedPdfPath);
//         } else {
//           showAnimatedToast("PDF file not found");
//         }
//       } catch (e) {
//         showAnimatedToast("Cannot open PDF: $e");
//       }
//     }
//   }

//   Future<void> _showLogoutDialog() async {
//     return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(),
//           title: const Text(
//             'Logout',
//             style: TextStyle(
//               color: Colors.black,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           content: const Text('Are you sure you want to logout?'),
//           actions: <Widget>[
//             TextButton(
//               child: Text(
//                 'Cancel',
//                 style: TextStyle(color: Colors.red.shade300),
//               ),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//             TextButton(
//               child: Text(
//                 'Logout',
//                 style: TextStyle(color: Colors.red.shade300),
//               ),
//               onPressed: () async {
//                 try {
//                   // Clear shared preferences
//                   final prefs = await SharedPreferences.getInstance();
//                   await prefs.clear();

//                   // Clear local database
//                   await DatabaseHelper.instance.clearDatabase();

//                   if (!mounted) return;

//                   // Navigate to Login Screen
//                   Navigator.of(context).pop();
//                   Navigator.pushReplacement(
//                     context,
//                     CupertinoPageRoute(
//                       builder: (context) => const LoginScreen(),
//                     ),
//                   );
//                 } catch (e) {
//                   showAnimatedToast('Error during logout: $e');
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _bannerAd?.dispose();
//     _rewardedAd?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_isInitialized || isLoading) {
//       return const Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }

//     return WillPopScope(
//       onWillPop: () async {
//         SystemNavigator.pop();
//         return false;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           title: Text(
//             'Products Screen',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 20.sp,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           backgroundColor: Colors.red.shade300,
//           actions: [
//             if (lastDownloadedPdfPath != null)
//               IconButton(
//                 icon: Icon(Icons.visibility, color: Colors.white, size: 24.sp),
//                 onPressed: _openPDF,
//               ),
//             // Add Product Button
//             IconButton(
//               icon: Icon(Icons.add, color: Colors.white, size: 24.sp),
//               onPressed: () async {
//                 if (userEmail != null) {
//                   final result = await Navigator.push(
//                     context,
//                     CupertinoPageRoute(
//                       builder: (context) => AddProductScreen(),
//                     ),
//                   );
//                   if (result == true) {
//                     _loadProducts();
//                   }
//                 }
//               },
//             ),
//             // Logout Button
//             IconButton(
//               icon: Icon(Icons.logout, color: Colors.white, size: 24.sp),
//               onPressed: _showLogoutDialog,
//             ),
//             // View PDF Button (if PDF exists)
//           ],
//         ),
//         body: Column(
//           children: [
//             if (_isAdLoaded && _bannerAd != null)
//               Container(
//                 alignment: Alignment.center,
//                 width: _bannerAd!.size.width.toDouble(),
//                 height: _bannerAd!.size.height.toDouble(),
//                 child: AdWidget(ad: _bannerAd!),
//               ),
//             Expanded(
//               child: RefreshIndicator(
//                 onRefresh: _loadProducts,
//                 child: _buildBody(),
//               ),
//             ),
//           ],
//         ),
//         floatingActionButton: FloatingActionButton(
//           heroTag: 'download',
//           onPressed: () {
//             if (products.isEmpty) {
//               showAnimatedToast(
//                   'Please add at least one product before generating PDF');
//               return;
//             }
//             _showRewardedAd();
//           },
//           backgroundColor: Colors.red.shade300,
//           child: const Icon(Icons.picture_as_pdf, color: Colors.white),
//         ),
//       ),
//     );
//   }

//   Widget _buildBody() {
//     if (isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (errorMessage != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(errorMessage!, style: const TextStyle(color: Colors.red)),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _loadProducts,
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }

//     if (products.isEmpty) {
//       return const Center(
//         child: Text('No products added yet'),
//       );
//     }

//     return GridView.builder(
//       padding: const EdgeInsets.all(8),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         childAspectRatio: 0.75,
//         crossAxisSpacing: 8,
//         mainAxisSpacing: 8,
//       ),
//       itemCount: products.length,
//       itemBuilder: (context, index) {
//         final product = products[index];
//         return Card(
//           elevation: 2,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 flex: 2,
//                 child: Stack(
//                   children: [
//                     ClipRRect(
//                       borderRadius:
//                           BorderRadius.vertical(top: Radius.circular(4.r)),
//                       child: _buildProductImage(product.image),
//                     ),
//                     Positioned(
//                       top: 0,
//                       right: 0,
//                       child: GestureDetector(
//                         onTap: () {
//                           _deleteProduct(product);
//                         },
//                         child: Icon(
//                           Icons.delete,
//                           size: 30,
//                           color: Colors.red.shade300,
//                         ),
//                       ),
//                       // child: IconButton(
//                       //   iconSize: 20.sp,
//                       //   padding: EdgeInsets.all(4),
//                       //   constraints: BoxConstraints(),
//                       //   icon: Icon(
//                       //     Icons.delete,
//                       //     color: Colors.red.shade300,
//                       //   ),
//                       //   onPressed: () => _deleteProduct(product),
//                       // ),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       product.description,
//                       style: TextStyle(
//                         fontSize: 12.sp,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     SizedBox(height: 4.h),
//                     Text(
//                       'Rs. ${product.price.toStringAsFixed(2)}',
//                       style: TextStyle(
//                         color: Colors.green,
//                         fontSize: 12.sp,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildProductImage(String? imagePath) {
//     if (imagePath == null) {
//       return Container(
//         color: Colors.grey[200],
//         child: const Icon(
//           Icons.image_not_supported,
//           color: Colors.grey,
//         ),
//       );
//     }

//     return Image.file(
//       File(imagePath),
//       fit: BoxFit.cover,
//       width: double.infinity,
//       height: 100,
//       errorBuilder: (context, error, stackTrace) {
//         return Container(
//           color: Colors.grey[200],
//           child: Icon(
//             Icons.image_not_supported,
//             color: Colors.grey,
//           ),
//         );
//       },
//     );
//   }
// }

import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:open_filex/open_filex.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as dev;
import '../../database/database_helper.dart';
import '../../helper/ad_helper.dart';
import '../../models/product_model.dart';
import '../add_product_form/add_product_screen.dart';
import '../login_screen/login_screen.dart';
// import '../login_screen/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [];
  bool isLoading = true;
  String? errorMessage;
  RewardedAd? _rewardedAd;
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  String? lastDownloadedPdfPath;
  String? userEmail;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
    // _initializeAds();
    _loadSavedPdfPath();
  }

  // Removed duplicate build method to resolve "The name 'build' is already defined" error.

  Future<void> _initialize() async {
    try {
      await _getUserEmail();
      if (userEmail != null) {
        await _loadProducts();
      }
      _initializeAds(); // Keep it here only
      setState(() {
        _isInitialized = true;
        isLoading = false;
      });
    } catch (e) {
      dev.log('Initialization error: $e');
      setState(() {
        errorMessage = 'Failed to initialize app';
        isLoading = false;
      });
    }
  }

  void _initializeAds() {
    _initBannerAd();
    _createRewardedAd();
  }

  void _initBannerAd() {
    try {
      _bannerAd?.dispose();
      _bannerAd = BannerAd(
        adUnitId: AdHelper.bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint('Banner ad loaded successfully');
            if (mounted) {
              setState(() {
                _isAdLoaded = true;
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('Banner ad failed to load: $error');
            ad.dispose();
            _bannerAd = null;
            if (mounted) {
              setState(() {
                _isAdLoaded = false;
              });
            }
            // Retry after delay
            Future.delayed(const Duration(seconds: 30), _initBannerAd);
          },
        ),
      );
      _bannerAd?.load();
    } catch (e) {
      debugPrint('Banner ad initialization error: $e');
      _isAdLoaded = false;
    }
  }

  void _generateAndDownloadPDF() async {
    if (products.isEmpty) {
      _showToast('No products to generate PDF');
      return;
    }
    try {
      final pdf = pw.Document();

      // Convert screen util dimensions to PDF points
      double pdfFontSize(double size) => size * (72 / 96);

      // Function to create a product cell
      pw.Widget buildProductCell(Product product) {
        pw.Widget productImage;

        // Handle image
        if (product.image != null && product.image!.isNotEmpty) {
          try {
            final file = File(product.image!);
            if (file.existsSync()) {
              productImage = pw.Image(
                pw.MemoryImage(file.readAsBytesSync()),
                height: 120,
                width: 120,
                fit: pw.BoxFit.cover,
              );
            } else {
              productImage = _buildNoImageContainer();
            }
          } catch (e) {
            productImage = _buildNoImageContainer();
          }
        } else {
          productImage = _buildNoImageContainer();
        }

        return pw.Container(
          height: 200,
          width: 160,
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              productImage,
              pw.SizedBox(height: 8),
              pw.Text(
                product.description,
                style: pw.TextStyle(
                  fontSize: pdfFontSize(12),
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
                maxLines: 2,
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Rs. ${product.price.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: pdfFontSize(12),
                  color: PdfColors.red,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          header: (pw.Context context) {
            return pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'Product Catalog',
                    style: pw.TextStyle(
                      fontSize: pdfFontSize(24),
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Total Products: ${products.length}',
                    style: pw.TextStyle(
                      fontSize: pdfFontSize(14),
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Divider(),
                ],
              ),
            );
          },
          build: (pw.Context context) {
            List<pw.Widget> pages = [];

            // Create rows with 3 products each
            for (var i = 0; i < products.length; i += 3) {
              final rowItems = <pw.Widget>[];

              // Add up to 3 products in this row
              for (var j = 0; j < 3 && (i + j) < products.length; j++) {
                rowItems.add(
                  pw.Expanded(
                    child: buildProductCell(products[i + j]),
                  ),
                );

                // Add spacing between products
                if (j < 2 && (i + j + 1) < products.length) {
                  rowItems.add(pw.SizedBox(width: 10));
                }
              }

              // Add the row to pages
              pages.add(
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: rowItems,
                ),
              );

              // Add spacing between rows
              if (i + 3 < products.length) {
                pages.add(pw.SizedBox(height: 20));
              }
            }

            return pages;
          },
        ),
      );

      // Get device info to handle permissions properly
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo? androidInfo;

      try {
        androidInfo = await deviceInfo.androidInfo;
      } catch (e) {
        debugPrint('Error getting device info: $e');
      }

      Directory? directory;
      bool hasPermission = false;

      if (Platform.isAndroid) {
        // Handle different Android versions
        if (androidInfo != null && androidInfo.version.sdkInt >= 33) {
          // Android 13+ - Use photos permission for media access
          hasPermission = await Permission.photos.isGranted;
          if (!hasPermission) {
            final status = await Permission.photos.request();
            hasPermission = status.isGranted;
          }
        } else if (androidInfo != null && androidInfo.version.sdkInt >= 29) {
          // Android 10-12 - Use storage + access media location
          final storageStatus = await Permission.storage.status;
          final mediaStatus = await Permission.accessMediaLocation.status;

          hasPermission = storageStatus.isGranted && mediaStatus.isGranted;

          if (!hasPermission) {
            final storageResult = await Permission.storage.request();
            final mediaResult = await Permission.accessMediaLocation.request();
            hasPermission = storageResult.isGranted && mediaResult.isGranted;
          }
        } else {
          // Android 9 and below - Use storage permission
          hasPermission = await Permission.storage.isGranted;
          if (!hasPermission) {
            final status = await Permission.storage.request();
            hasPermission = status.isGranted;
          }
        }

        if (hasPermission) {
          // Try to get Downloads directory first
          try {
            final downloadsDir = Directory('/storage/emulated/0/Download');
            if (await downloadsDir.exists()) {
              directory = downloadsDir;
            } else {
              // Fallback to external storage directory
              directory = await getExternalStorageDirectory();
            }
          } catch (e) {
            debugPrint('Error accessing downloads directory: $e');
            directory = await getExternalStorageDirectory();
          }
        }
      } else if (Platform.isIOS) {
        // For iOS, use documents directory
        directory = await getApplicationDocumentsDirectory();
        hasPermission =
            true; // iOS doesn't need explicit storage permission for documents directory
      }

      if (hasPermission && directory != null) {
        try {
          final file = File('ProductCatalog.pdf');
          await file.writeAsBytes(await pdf.save());

          // Store the exact path to the saved file
          final String filePath = file.path;

          if (mounted) {
            setState(() {
              lastDownloadedPdfPath = filePath;
            });

            // Optionally save the path to SharedPreferences for persistence across app restarts
            _savePdfPathToPrefs(filePath);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PDF Downloaded Successfully'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          debugPrint('Error saving PDF: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to save PDF: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Storage permission denied or directory not accessible. Cannot save PDF.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

// Save PDF path to SharedPreferences for persistence
  Future<void> _savePdfPathToPrefs(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_pdf_path', path);
  }

// Load PDF path from SharedPreferences during initialization
  Future<void> _loadSavedPdfPath() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString('last_pdf_path');
    if (savedPath != null) {
      setState(() {
        lastDownloadedPdfPath = savedPath;
      });
    }
  }

  pw.Widget _buildNoImageContainer() {
    return pw.Container(
      height: 120,
      width: 120,
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        border: pw.Border.all(color: PdfColors.grey400),
      ),
      child: pw.Center(
        child: pw.Text(
          'No Image',
          style: pw.TextStyle(
            color: PdfColors.grey600,
          ),
        ),
      ),
    );
  }

  Future<void> _openPDF() async {
    if (lastDownloadedPdfPath != null) {
      try {
        final file = File(lastDownloadedPdfPath!);
        if (await file.exists()) {
          // Use open_filex package
          final result = await OpenFile.open(lastDownloadedPdfPath!);

          if (result.type != 0) {
            // Error occurred
            // _showToast("Error opening PDF: ${result.message}");
            log("Error opening PDF: ${result.message}");
          }
        } else {
          if (mounted) {
            _showToast("PDF file not found at path: $lastDownloadedPdfPath");
          }
        }
      } catch (e) {
        if (mounted) {
          _showToast("Cannot open PDF: $e");
        }
      }
    } else {
      _showToast("No PDF has been generated yet");
    }
  }

  void _createRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.getRewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('Rewarded ad loaded successfully');
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded ad failed to load: $error');
          _rewardedAd = null;
          // Retry after delay
          Future.delayed(const Duration(seconds: 30), _createRewardedAd);
        },
      ),
    );
  }

  void _showRewardedAd() {
    if (_rewardedAd == null) {
      debugPrint('Rewarded ad not ready, generating PDF directly');
      _generateAndDownloadPDF();
      _createRewardedAd(); // Try to load for next time
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        debugPrint('Rewarded ad dismissed');
        ad.dispose();
        _createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        debugPrint('Rewarded ad failed to show: $error');
        ad.dispose();
        _createRewardedAd();
        _generateAndDownloadPDF();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
      onUserEarnedReward: (_, reward) {
        debugPrint('User earned reward: ${reward.amount} ${reward.type}');
        _generateAndDownloadPDF();
      },
    );
    _rewardedAd = null;
  }

  Future<void> _getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // First check if user is logged in
      bool isLoggedIn =
          prefs.getBool('isLoggedIn') ?? false; // Default to false if null
      String? email = prefs.getString('user_email');

      if (!isLoggedIn || email == null || email.isEmpty) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            CupertinoPageRoute(builder: (context) => const LoginScreen()),
          );
        }
        return;
      }

      setState(() {
        userEmail = email;
      });
    } catch (e) {
      throw Exception('Failed to get user email');
    }
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;

    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      if (userEmail == null) {
        throw Exception('User email not available');
      }

      final productsList =
          await DatabaseHelper.instance.getAllProductsForUser(userEmail!);

      if (mounted) {
        setState(() {
          products = productsList;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load products';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteProduct(Product product) async {
    try {
      bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Delete'),
            content:
                const Text('Are you sure you want to delete this product?'),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: Text('Delete', style: TextStyle(color: Colors.red[300])),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        setState(() => isLoading = true);

        final result = await DatabaseHelper.instance
            .deleteProduct(product.id!, userEmail!);

        if (result > 0) {
          if (product.image != null && product.image!.isNotEmpty) {
            final file = File(product.image!);
            if (await file.exists()) {
              await file.delete();
            }
          }

          setState(() {
            products.removeWhere((p) => p.id == product.id);
            isLoading = false;
          });

          _showToast('Product deleted successfully');
        } else {
          _showToast('Failed to delete product');
        }
      }
    } catch (e) {
      _showToast('Error deleting product');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showToast(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.withOpacity(0.8) : Colors.black87,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // void _generateAndDownloadPDF() async {
  //   if (products.isEmpty) {
  //     _showToast('No products to generate PDF');
  //     return;
  //   }
  //   try {
  //     final pdf = pw.Document();

  //     // Convert screen util dimensions to PDF points
  //     double pdfFontSize(double size) => size * (72 / 96);

  //     // Function to create a product cell
  //     pw.Widget buildProductCell(Product product) {
  //       pw.Widget productImage;

  //       // Handle image
  //       if (product.image != null && product.image!.isNotEmpty) {
  //         try {
  //           final file = File(product.image!);
  //           if (file.existsSync()) {
  //             productImage = pw.Image(
  //               pw.MemoryImage(file.readAsBytesSync()),
  //               height: 120,
  //               width: 120,
  //               fit: pw.BoxFit.cover,
  //             );
  //           } else {
  //             productImage = _buildNoImageContainer();
  //           }
  //         } catch (e) {
  //           productImage = _buildNoImageContainer();
  //         }
  //       } else {
  //         productImage = _buildNoImageContainer();
  //       }

  //       return pw.Container(
  //         height: 200,
  //         width: 160,
  //         padding: const pw.EdgeInsets.all(8),
  //         decoration: pw.BoxDecoration(
  //           border: pw.Border.all(color: PdfColors.grey300),
  //         ),
  //         child: pw.Column(
  //           crossAxisAlignment: pw.CrossAxisAlignment.center,
  //           children: [
  //             productImage,
  //             pw.SizedBox(height: 8),
  //             pw.Text(
  //               product.description,
  //               style: pw.TextStyle(
  //                 fontSize: pdfFontSize(12),
  //                 fontWeight: pw.FontWeight.bold,
  //               ),
  //               textAlign: pw.TextAlign.center,
  //               maxLines: 2,
  //             ),
  //             pw.SizedBox(height: 4),
  //             pw.Text(
  //               'Rs. ${product.price.toStringAsFixed(2)}',
  //               style: pw.TextStyle(
  //                 fontSize: pdfFontSize(12),
  //                 color: PdfColors.red,
  //                 fontWeight: pw.FontWeight.bold,
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     }

  //     pdf.addPage(
  //       pw.MultiPage(
  //         pageFormat: PdfPageFormat.a4,
  //         margin: const pw.EdgeInsets.all(40),
  //         header: (pw.Context context) {
  //           return pw.Container(
  //             padding: const pw.EdgeInsets.only(bottom: 20),
  //             child: pw.Column(
  //               crossAxisAlignment: pw.CrossAxisAlignment.center,
  //               children: [
  //                 pw.Text(
  //                   'Product Catalog',
  //                   style: pw.TextStyle(
  //                     fontSize: pdfFontSize(24),
  //                     fontWeight: pw.FontWeight.bold,
  //                   ),
  //                 ),
  //                 pw.SizedBox(height: 10),
  //                 pw.Text(
  //                   'Total Products: ${products.length}',
  //                   style: pw.TextStyle(
  //                     fontSize: pdfFontSize(14),
  //                     color: PdfColors.grey700,
  //                   ),
  //                 ),
  //                 pw.Divider(),
  //               ],
  //             ),
  //           );
  //         },
  //         build: (pw.Context context) {
  //           List<pw.Widget> pages = [];

  //           // Create rows with 3 products each
  //           for (var i = 0; i < products.length; i += 3) {
  //             final rowItems = <pw.Widget>[];

  //             // Add up to 3 products in this row
  //             for (var j = 0; j < 3 && (i + j) < products.length; j++) {
  //               rowItems.add(
  //                 pw.Expanded(
  //                   child: buildProductCell(products[i + j]),
  //                 ),
  //               );

  //               // Add spacing between products
  //               if (j < 2 && (i + j + 1) < products.length) {
  //                 rowItems.add(pw.SizedBox(width: 10));
  //               }
  //             }

  //             // Add the row to pages
  //             pages.add(
  //               pw.Row(
  //                 crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                 children: rowItems,
  //               ),
  //             );

  //             // Add spacing between rows
  //             if (i + 3 < products.length) {
  //               pages.add(pw.SizedBox(height: 20));
  //             }
  //           }

  //           return pages;
  //         },
  //       ),
  //     );

  //     // Save PDF to downloads folder
  //     final directory = Directory("/storage/emulated/0/Download");
  //     if (!directory.existsSync()) {
  //       directory.createSync(recursive: true);
  //     }

  //     final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  //     final file = File('${directory.path}/ProductCatalog_$timestamp.pdf');
  //     final String fileName = 'Catalog.pdf';
  //     await file.writeAsBytes(await pdf.save());
  //     final String filePath = '${directory.path}/$fileName';

  //     if (mounted) {
  //       setState(() {
  //         lastDownloadedPdfPath = filePath;
  //       });
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('PDF Downloaded Successfully'),
  //           backgroundColor: Colors.green,
  //           duration: Duration(seconds: 2),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Failed to generate PDF: $e'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }

  // pw.Widget _buildNoImageContainer() {
  //   return pw.Container(
  //     height: 120,
  //     width: 120,
  //     decoration: pw.BoxDecoration(
  //       color: PdfColors.grey200,
  //       border: pw.Border.all(color: PdfColors.grey400),
  //     ),
  //     child: pw.Center(
  //       child: pw.Text(
  //         'No Image',
  //         style: pw.TextStyle(
  //           color: PdfColors.grey600,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Future<void> _openPDF() async {
  //   if (lastDownloadedPdfPath != null) {
  //     try {
  //       final file = File(lastDownloadedPdfPath!);
  //       if (await file.exists()) {
  //         await OpenFile.open(lastDownloadedPdfPath);
  //       } else {
  //         if (mounted) {
  //           _showToast("PDF file not found");
  //         }
  //       }
  //     } catch (e) {
  //       if (mounted) {
  //         _showToast("Cannot open PDF: $e");
  //       }
  //     }
  //   }
  // }

  Future<void> _showLogoutDialog() async {
    final bool? logout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(color: Colors.red[300])),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text('Logout', style: TextStyle(color: Colors.red[300])),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (logout == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        await DatabaseHelper.instance.clearDatabase();

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => const LoginScreen()),
        );
      } catch (e) {
        _showToast('Error during logout');
      }
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    if (!_isInitialized || isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Products Screen',
            style: TextStyle(
              color: Colors.white,
              fontSize: screenSize.width * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.red[300],
          actions: [
            if (lastDownloadedPdfPath != null)
              IconButton(
                icon: Icon(
                  Icons.visibility,
                  color: Colors.white,
                  size: screenSize.width * 0.06,
                ),
                onPressed: _openPDF,
              ),
            IconButton(
              icon: Icon(
                Icons.add,
                color: Colors.white,
                size: screenSize.width * 0.06,
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => const AddProductScreen()),
                );
                if (result == true) {
                  _loadProducts();
                }
              },
            ),
            IconButton(
              icon: Icon(
                Icons.logout,
                color: Colors.white,
                size: screenSize.width * 0.06,
              ),
              onPressed: _showLogoutDialog,
            ),
          ],
        ),
        body: Column(
          children: [
            if (_isAdLoaded &&
                _bannerAd != null) // Only show when both conditions are true
              Container(
                alignment: Alignment.center,
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadProducts,
                child: _buildProductGrid(screenSize),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'download',
          onPressed: () {
            if (products.isEmpty) {
              _showToast(
                  'Please add at least one product before generating PDF');
              return;
            }
            _showRewardedAd();
          },
          backgroundColor: Colors.red[300],
          child: const Icon(Icons.picture_as_pdf, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildProductGrid(Size screenSize) {
    if (products.isEmpty) {
      return const Center(child: Text('No products added yet'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(4)),
                      child: _buildProductImage(product.image),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        child: Icon(Icons.delete, color: Colors.red[300]),
                        onTap: () => _deleteProduct(product),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: screenSize.width * 0.03,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: screenSize.height * 0.005),
                    Text(
                      'Rs. ${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: screenSize.width * 0.03,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Icon(
          Icons.image_not_supported,
          color: Colors.grey,
        ),
      );
    }

    return Image.file(
      File(imagePath),
      fit: BoxFit.cover,
      width: double.infinity,
      height: 100,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[200],
          child: const Icon(
            Icons.image_not_supported,
            color: Colors.grey,
          ),
        );
      },
    );
  }
}
