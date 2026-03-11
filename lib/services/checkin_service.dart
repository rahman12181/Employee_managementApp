import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:management_app/services/auth_service.dart';
import 'package:management_app/services/connectivity_service.dart';
import 'package:intl/intl.dart';

class CheckinService {
  final ConnectivityService _connectivityService = ConnectivityService();

  Future<Map<String, dynamic>> checkIn({
    required String employeeId,
    required String logType,
    required Position currentPosition,
  }) async {
    
    try {
      // Internet check
      bool hasInternet = await _connectivityService.hasInternetConnection();
      
      if (!hasInternet) {
        return {
          'success': false,
          'offlineMode': true,
          'message': 'No internet connection. Punch saved locally.',
        };
      }

      // Riyadh time
      final riyadhTime = DateTime.now().toUtc().add(const Duration(hours: 3));
      final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(riyadhTime);

      // API Body
      Map<String, dynamic> requestBody = {
        "employee": employeeId,
        "log_type": logType,
        "time": formattedTime,
        "latitude": currentPosition.latitude,
        "longitude": currentPosition.longitude,
      };

      // API Call
      final apiResponse = await AuthService.client.post(
        Uri.parse("https://ppecon.erpnext.com/api/resource/Employee%20Checkin"),
        headers: {
          "Content-Type": "application/json",
          "Cookie": AuthService.cookies.join("; "),
        },
        body: jsonEncode(requestBody),
      );

      // Parse response
      Map<String, dynamic> responseData = {};
      String message = '';
      bool success = apiResponse.statusCode == 200 || apiResponse.statusCode == 201;

      try {
        responseData = jsonDecode(apiResponse.body);
        
        // Extract message from _server_messages
        if (responseData['_server_messages'] != null) {
          try {
            var messages = jsonDecode(responseData['_server_messages']);
            if (messages.isNotEmpty) {
              var msgObj = jsonDecode(messages[0]);
              message = msgObj['message'] ?? '';
              message = message.replaceAll('✅', '').replaceAll('❌', '').trim();
            }
          } catch (_) {}
        }
        
        if (message.isEmpty) {
          message = responseData['exception'] ?? 
                   responseData['message'] ??
                   (success ? 'Punch successful' : 'Punch failed');
        }
      } catch (e) {
        message = success ? 'Punch successful' : 'Punch failed';
      }

      return {
        'success': success,
        'message': message,
        'data': responseData['data'],
        'statusCode': apiResponse.statusCode,
        'offlineMode': false,
      };

    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
        'offlineMode': false,
      };
    }
  }

  // Checkout method
  Future<Map<String, dynamic>> checkOut({
    required String employeeId,
    required Position currentPosition,
  }) async {
    return await checkIn(
      employeeId: employeeId,
      logType: "OUT",
      currentPosition: currentPosition,
    );
  }
}