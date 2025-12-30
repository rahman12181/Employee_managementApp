import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:management_app/model/leave_approved_model.dart';

class LeaveApprovedService {
  static Future<List<LeaveApprovedModel>> fetchApprovedLeaves() async {
    final response = await http.get(
      Uri.parse("https://your-api-url.com/leave-list"),
      headers: {
        "Authorization": "Bearer YOUR_TOKEN",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      /// ✅ ONLY APPROVED
      return data
          .where((e) => e['status'] == "Approved")
          .map((e) => LeaveApprovedModel.fromJson(e))
          .toList();
    } else {
      throw Exception("Failed to fetch approved leave list");
    }
  }
}
