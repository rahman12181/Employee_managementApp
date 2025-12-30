import 'package:flutter/material.dart';
import 'package:management_app/model/leave_approved_model.dart';

class LeaveDetailScreen extends StatelessWidget {
  final LeaveApprovedModel leave;

  const LeaveDetailScreen({super.key, required this.leave});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leave Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _row("Employee Name",
                    leave.employeeName),
                _row("Leave Type",
                    leave.leaveType),
                _row("From Date",
                    leave.fromDate),
                _row("To Date",
                    leave.toDate),
                _row("Status", leave.status),
                _row("Reason", leave.reason),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
