import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const String _baseUrl = "https://ppecon.erpnext.com";

  // 🔥 NEW: Get user profile using EMAIL (not employeeId)
  static Future<Map<String, dynamic>> getUserProfile(String userEmail) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cookies = prefs.getStringList("cookies");

      if (cookies == null || cookies.isEmpty) {
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'data': null,
        };
      }

      // ✅ CORRECT API: User doctype with email
      final url = Uri.parse("$_baseUrl/api/resource/User/$userEmail");

      print("📡 Fetching User profile for: $userEmail");
      print("📡 URL: $url");

      final response = await http.get(
        url,
        headers: {
          "Cookie": cookies.join("; "),
          "Accept": "application/json",
        },
      );

      print("📥 Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        
        if (decoded["data"] != null) {
          Map<String, dynamic> userData = decoded["data"];
          
          // ✅ FIX: Construct full image URL from user_image field
          if (userData['user_image'] != null && userData['user_image'].toString().isNotEmpty) {
            String imagePath = userData['user_image'].toString();
            if (!imagePath.startsWith('http')) {
              userData['full_image_url'] = "$_baseUrl$imagePath";
            } else {
              userData['full_image_url'] = imagePath;
            }
            print("🖼️ Image URL: ${userData['full_image_url']}");
          } else {
            print("⚠️ No user_image found in response");
            userData['full_image_url'] = null;
          }
          
          return {
            'success': true,
            'message': 'Profile fetched successfully',
            'data': userData,
          };
        } else {
          return {
            'success': false,
            'message': 'User not found',
            'data': null,
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Failed to load profile: ${response.statusCode}',
          'data': null,
        };
      }
    } catch (e) {
      print("❌ Error: $e");
      return {
        'success': false,
        'message': e.toString(),
        'data': null,
      };
    }
  }

  // Keep existing helper methods (unchanged)
  static String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  static int getAge(String? dobStr) {
    if (dobStr == null || dobStr.isEmpty) return 0;
    try {
      final dob = DateTime.parse(dobStr);
      final today = DateTime.now();
      int age = today.year - dob.year;
      if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }

  static Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      case 'suspended':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  static IconData getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Icons.check_circle_rounded;
      case 'inactive':
        return Icons.cancel_rounded;
      case 'suspended':
        return Icons.pause_circle_rounded;
      default:
        return Icons.help_rounded;
    }
  }
}