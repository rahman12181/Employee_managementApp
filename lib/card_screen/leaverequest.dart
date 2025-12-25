import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:management_app/services/leave_request_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaveRequest extends StatefulWidget {
  const LeaveRequest({super.key});
  @override
  State<LeaveRequest> createState() => _LeaveRequestState();
}

class _LeaveRequestState extends State<LeaveRequest> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final TextEditingController fromDateCtrl = TextEditingController();
  final TextEditingController toDateCtrl = TextEditingController();
  final TextEditingController reasonCtrl = TextEditingController();
  final TextEditingController empCodeCtrl = TextEditingController();
  final TextEditingController empNameCtrl = TextEditingController();
  final TextEditingController inchargeCtrl = TextEditingController();

  String? leaveType;
  String compOff = "NO";

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  Future<void> _loadEmployeeData() async {
    final prefs = await SharedPreferences.getInstance();
    empCodeCtrl.text = prefs.getString("employeeId") ?? "HR-EMP-0015";
    final profileData = prefs.getString("profileData");
    if (profileData != null) {
      final data = jsonDecode(profileData);
      empNameCtrl.text = data["full_name"] ?? "";
    }
  }

  Future<void> selectDate(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      controller.text =
          "${pickedDate.day.toString().padLeft(2, '0')}-"
          "${pickedDate.month.toString().padLeft(2, '0')}-"
          "${pickedDate.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        title: const Text(
          "Leave Request",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Leave Type
              const Text(
                "Leave Type",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              DropdownButtonFormField<String>(
                dropdownColor: Colors.white.withAlpha(230),
                style: const TextStyle(color: Colors.black, fontSize: 15),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.black54,
                ),
                decoration: InputDecoration(
                  hintText: "Select leave type",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: "CL", child: Text("Casual Leave")),
                  DropdownMenuItem(value: "SL", child: Text("Sick Leave")),
                  DropdownMenuItem(value: "EL", child: Text("Earned Leave")),
                ],
                onChanged: (value) => leaveType = value,
                validator: (value) =>
                    value == null ? "Select leave type" : null,
              ),

              SizedBox(height: screenHeight * 0.02),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: fromDateCtrl,
                      readOnly: true,
                      onTap: () => selectDate(fromDateCtrl),
                      decoration: InputDecoration(
                        hintText: "From date",
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Select from date" : null,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: TextFormField(
                      controller: toDateCtrl,
                      readOnly: true,
                      onTap: () => selectDate(toDateCtrl),
                      decoration: InputDecoration(
                        hintText: "To date",
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Select to date" : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),

              // Reason
              const Text(
                "Reason for leave",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              TextFormField(
                controller: reasonCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Enter reason",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Reason is required" : null,
              ),
              SizedBox(height: screenHeight * 0.02),

              // Comp Off
              const Text(
                "Is it a Comp Off?",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              Row(
                children: ["NO", "YES"].map((e) {
                  final isSelected = compOff == e;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => compOff = e),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.015,
                        ),
                        margin: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.01,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.transparent,
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            e,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Incharge Replacement
              const Text(
                "Incharge Replacement",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              TextFormField(
                controller: inchargeCtrl,
                decoration: InputDecoration(
                  hintText: "Enter incharge replacement",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) => value!.isEmpty ? "Enter incharge" : null,
              ),
              SizedBox(height: screenHeight * 0.03),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: screenHeight * 0.06,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: _isLoading ? null : _submitLeave,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "SUBMIT",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitLeave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await LeaveRequestService.submitLeave(
      employeeCode: empCodeCtrl.text.trim(),
      leaveType: LeaveRequestService.mapLeaveType(leaveType),
      fromDate: fromDateCtrl.text,
      toDate: toDateCtrl.text,
      reason: reasonCtrl.text.trim(),
      compOff: compOff,
      inchargeReplacement: inchargeCtrl.text.trim(),
    );

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result["success"] == true
              ? "Leave applied successfully"
              : result["message"],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: result["success"] == true ? Colors.green : Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        duration: const Duration(seconds: 2),
      ),
    );

    if (result["success"] == true) {
      _formKey.currentState!.reset();
      fromDateCtrl.clear();
      toDateCtrl.clear();
      reasonCtrl.clear();
      inchargeCtrl.clear();
    }
  }
}
