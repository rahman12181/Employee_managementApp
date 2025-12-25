import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TravelRequestService {
  static const String _url =
      "https://ppecon.erpnext.com/api/resource/Travel%20Request";

  static Future<String> submitTravelRequest({
    required String travelType,
    required String travelFunding,
    required String purpose,
    required String from,
    required String to,
    required String mode,
    required String departureDate,
    required String description,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cookies = prefs.getStringList("cookies");
      final employeeId = prefs.getString("employeeId");

      if (cookies == null || cookies.isEmpty || employeeId == null) {
        throw "Session expired. Please login again.";
      }

      final response = await http.post(
        Uri.parse(_url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Cookie": cookies.join("; "),
        },
        body: jsonEncode({
          "employee": employeeId,
          "travel_type": travelType,
          "travel_funding": travelFunding,
          "purpose_of_travel": purpose,
          "itinerary": [
            {
              "travel_from": from,
              "travel_to": to,
              "mode_of_travel": mode,
              "departure_date": departureDate,
            }
          ],
          "description": description,
        }),
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return "Travel request submitted successfully";
      }

      if (decoded is Map) {
        if (decoded["_error_message"] != null) {
          throw decoded["_error_message"];
        }
        if (decoded["exception"] != null) {
          throw "Something went wrong. Please try again.";
        }
        if (decoded["message"] != null) {
          throw decoded["message"];
        }
      }

      throw "Failed to submit travel request (${response.statusCode})";
    } catch (e) {
      throw e.toString().replaceAll("Exception:", "").trim();
    }
  }
}
