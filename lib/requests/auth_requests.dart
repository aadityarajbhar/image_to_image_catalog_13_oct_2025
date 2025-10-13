import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class ApiResponse {
  final String status;
  final String message;

  ApiResponse({required this.status, required this.message});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      status: json['status'] ?? 'error',
      message: json['message'] ?? 'Unknown error occurred',
    );
  }
}

class AuthRequests {
  static final AuthRequests _instance = AuthRequests._internal();
  factory AuthRequests() => _instance;
  AuthRequests._internal();

  Future<ApiResponse> emailOtp(String email) async {
    try {
      if (email.isEmpty) {
        return ApiResponse(status: 'error', message: 'Email is required');
      }

      final url = Uri.parse(
        "https://techfluxsolutions.com/super_catelog_maker/send_mail_api.php",
      );

      // Changed to use form-encoded data instead of JSON
      final response = await http.post(
        url,
        body: {
          'email': email,
        },
        // Removed JSON headers since we're using form data
      );

      log('Email OTP Response: ${response.body}');

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(jsonDecode(response.body));
      } else {
        return ApiResponse(
          status: 'error',
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      log('Error sending OTP: $e');
      return ApiResponse(
        status: 'error',
        message: 'Failed to send OTP. Please try again.',
      );
    }
  }

  Future<ApiResponse> verifyOtp(String email, String otp) async {
    try {
      if (email.isEmpty || otp.isEmpty) {
        return ApiResponse(
          status: 'error',
          message: 'Email and OTP are required',
        );
      }

      final url = Uri.parse(
        "https://techfluxsolutions.com/super_catelog_maker/verify_otp_api.php",
      );

      // Changed to use form-encoded data instead of JSON
      final response = await http.post(
        url,
        body: {
          'email': email,
          'otp': otp,
        },
        // Removed JSON headers since we're using form data
      );

      log('Verify OTP Response: ${response.body}');

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(jsonDecode(response.body));
      } else {
        return ApiResponse(
          status: 'error',
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      log('Error verifying OTP: $e');
      return ApiResponse(
        status: 'error',
        message: 'Failed to verify OTP. Please try again.',
      );
    }
  }
}
