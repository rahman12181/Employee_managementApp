import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TravelRequestService {
  static const String _baseUrl = "https://ppecon.erpnext.com";

  static const String _customTravelApi =
      "$_baseUrl/api/method/ppecon_erp.travel_request.travel_request.submit_travel_request_from_mobile";

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
        Uri.parse(_customTravelApi),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Cookie": cookies.join("; "),
        },
        body: jsonEncode({
          "employee": employeeId,
          "personal_id_type": "Iqama",
          "personal_id_number": "1234567890",
          "travel_type": travelType,
          "travel_funding": travelFunding,
          "purpose_of_travel": purpose,
          "description": description,
          "itinerary": [
            {
              "travel_from": from,
              "travel_to": to,
              "mode_of_travel": mode,
              "departure_date": departureDate,
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        return "Travel Request Submitted Successfully";
      }

      throw "Submit Failed: ${response.body}";
    } catch (e) {
      throw e.toString();
    }
  }

  // =====================================================
  // GET MY TRAVEL REQUESTS (FINAL FIX)
  // =====================================================

  static Future<List<Map<String, dynamic>>> getMyTravelRequests(
      String employeeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final cookies = prefs.getStringList("cookies");

      if (cookies == null || cookies.isEmpty) {
        throw "Please login again";
      }

      final url =
          "$_baseUrl/api/resource/Travel%20Request"
          "?fields=[\"name\",\"employee\",\"employee_name\",\"travel_type\",\"purpose_of_travel\",\"travel_funding\",\"workflow_state\",\"description\",\"creation\",\"docstatus\"]"
          "&filters=[[\"employee\",\"=\",\"$employeeId\"]]"
          "&order_by=creation desc"
          "&limit=100";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Cookie": cookies.join("; "),
          "Accept": "application/json",
        },
      );

      if (response.statusCode != 200) {
        throw "ERP Error: ${response.body}";
      }

      final decoded = jsonDecode(response.body);

      final List data = decoded["data"];

      List<Map<String, dynamic>> travelRequests = [];

      for (var item in data) {
        final status = _getDisplayStatus(
          item["workflow_state"],
          item["docstatus"],
        );

        travelRequests.add({
          "type": "travel",

          "data": item,

          // UI
          "id": item["name"] ?? "",
          "title": "Travel: ${item["travel_type"] ?? ""}",
          "subtitle": item["purpose_of_travel"] ?? "",
          "date": item["creation"] ?? "",

          "status": status,

          "color": _getStatusColor(
            item["workflow_state"],
            item["docstatus"],
          ),

          "icon": Icons.flight_takeoff,

          // Details
          "purpose_of_travel": item["purpose_of_travel"] ?? "",
          "travel_type": item["travel_type"] ?? "",
          "travel_funding": item["travel_funding"] ?? "",
          "created_on": item["creation"] ?? "",

          "workflow_state": item["workflow_state"] ?? "",
          "docstatus": item["docstatus"] ?? 0,
        });
      }

      return travelRequests;
    } catch (e) {
      rethrow;
    }
  }


  static String _getDisplayStatus(String? workflowState, int? docstatus) {
    if (workflowState == "Direct Manager Approval") {
      return "Pending (Manager)";
    }

    if (workflowState == "HR Approval") {
      return "Pending (HR)";
    }

    if (workflowState == "Approved") {
      return "Approved";
    }

    if (workflowState == "Rejected") {
      return "Rejected";
    }

    if (docstatus == 0) return "Draft";
    if (docstatus == 1) return "Submitted";
    if (docstatus == 2) return "Cancelled";

    return "Pending";
  }



  static Color _getStatusColor(String? workflowState, int? docstatus) {
    final status =
        _getDisplayStatus(workflowState, docstatus).toLowerCase();

    switch (status) {
      case "approved":
        return Colors.green;

      case "rejected":
        return Colors.red;

      case "cancelled":
        return Colors.grey;

      default:
        return Colors.orange;
    }
  }
}
