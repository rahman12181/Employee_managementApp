import 'dart:convert';
import 'dart:io';
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
  bool _showSuccessDialog = false;
  bool _showErrorDialog = false;
  String _errorMessage = "";

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
    empCodeCtrl.text = prefs.getString("employeeId") ?? "";
    final profileData = prefs.getString("profileData");
    if (profileData != null) {
      try {
        final data = jsonDecode(profileData);
        empNameCtrl.text = data["full_name"] ?? "";
      } catch (_) {}
    }
  }

  Future<void> selectDate(TextEditingController controller) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
            dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null) {
      controller.text =
          "${pickedDate.day.toString().padLeft(2, '0')}-"
          "${pickedDate.month.toString().padLeft(2, '0')}-"
          "${pickedDate.year}";
    }
  }

  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  void _showSuccessPopup() {
    setState(() {
      _showSuccessDialog = true;
      _showErrorDialog = false;
    });
  }

  void _showErrorPopup(String message) {
    setState(() {
      _errorMessage = message;
      _showErrorDialog = true;
      _showSuccessDialog = false;
    });
  }

  void _closeDialogs() {
    setState(() {
      _showSuccessDialog = false;
      _showErrorDialog = false;
    });
  }

  void _navigateToDashboard() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    // MediaQuery for responsive design
    final mediaQuery = MediaQuery.of(context);
    final isDarkMode = mediaQuery.platformBrightness == Brightness.dark;
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isSmallScreen = screenWidth < 360;
    final paddingValue = isSmallScreen ? 12.0 : 16.0;

    // Colors based on theme
    final backgroundColor = isDarkMode ? Colors.grey[900]! : const Color(0xffF5F6FA);
    final cardColor = isDarkMode ? Colors.grey[800]! : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final hintTextColor = isDarkMode ? Colors.grey[400] : Colors.black54;
    final borderColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
    final buttonColor = Theme.of(context).primaryColor;
    final successColor = Colors.green;
    final errorColor = Colors.red;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "Leave Request",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [Colors.blue[900]!, Colors.blue[800]!]
                  : [const Color(0xFF1565C0), const Color(0xFF1E88E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(paddingValue),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Leave Type",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: hintTextColor,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  DropdownButtonFormField<String>(
                    dropdownColor: cardColor,
                    style: TextStyle(
                      color: textColor,
                      fontSize: isSmallScreen ? 14 : 15,
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: hintTextColor,
                    ),
                    decoration: InputDecoration(
                      hintText: "Select leave type",
                      hintStyle: TextStyle(color: hintTextColor),
                      filled: true,
                      fillColor: cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 16,
                        vertical: isSmallScreen ? 14 : 16,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: "CL", child: Text("Casual Leave")),
                      DropdownMenuItem(value: "SL", child: Text("Sick Leave")),
                      DropdownMenuItem(value: "EL", child: Text("Earned Leave")),
                    ],
                    onChanged: (value) => setState(() => leaveType = value),
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
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: "From date",
                            hintStyle: TextStyle(color: hintTextColor),
                            filled: true,
                            fillColor: cardColor,
                            suffixIcon: Icon(Icons.calendar_today, 
                                size: isSmallScreen ? 18 : 20, 
                                color: hintTextColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 12 : 16,
                              vertical: isSmallScreen ? 14 : 16,
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
                          style: TextStyle(color: textColor),
                          decoration: InputDecoration(
                            hintText: "To date",
                            hintStyle: TextStyle(color: hintTextColor),
                            filled: true,
                            fillColor: cardColor,
                            suffixIcon: Icon(Icons.calendar_today, 
                                size: isSmallScreen ? 18 : 20, 
                                color: hintTextColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 12 : 16,
                              vertical: isSmallScreen ? 14 : 16,
                            ),
                          ),
                          validator: (value) =>
                              value!.isEmpty ? "Select to date" : null,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  Text(
                    "Reason for leave",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: hintTextColor,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  TextFormField(
                    controller: reasonCtrl,
                    maxLines: 3,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: "Enter reason",
                      hintStyle: TextStyle(color: hintTextColor),
                      filled: true,
                      fillColor: cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 16,
                        vertical: isSmallScreen ? 14 : 16,
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Reason is required" : null,
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  Text(
                    "Is it a Comp Off?",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: hintTextColor,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
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
                              color: isSelected ? buttonColor : Colors.transparent,
                              border: Border.all(color: buttonColor),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Text(
                                e,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : buttonColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: isSmallScreen ? 14 : 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  Text(
                    "Incharge Replacement",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: hintTextColor,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  TextFormField(
                    controller: inchargeCtrl,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: "Enter incharge replacement",
                      hintStyle: TextStyle(color: hintTextColor),
                      filled: true,
                      fillColor: cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 16,
                        vertical: isSmallScreen ? 14 : 16,
                      ),
                    ),
                    validator: (value) => value!.isEmpty ? "Enter incharge" : null,
                  ),

                  SizedBox(height: screenHeight * 0.04),

                  SizedBox(
                    width: double.infinity,
                    height: screenHeight * 0.06,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 2,
                      ),
                      onPressed: _isLoading ? null : _submitLeave,
                      child: _isLoading
                          ? SizedBox(
                              width: isSmallScreen ? 18 : 20,
                              height: isSmallScreen ? 18 : 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              "SUBMIT",
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Success Dialog
          if (_showSuccessDialog)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  width: screenWidth * 0.85,
                  padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: isSmallScreen ? 70 : 80,
                        height: isSmallScreen ? 70 : 80,
                        decoration: BoxDecoration(
                          color: successColor.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          size: isSmallScreen ? 45 : 50,
                          color: successColor,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 20),
                      Text(
                        "Success!",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 20 : 22,
                          fontWeight: FontWeight.bold,
                          color: successColor,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 10),
                      Text(
                        "Leave applied successfully",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isSmallScreen ? 20 : 25),
                      SizedBox(
                        width: double.infinity,
                        height: isSmallScreen ? 45 : 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _navigateToDashboard,
                          child: Text(
                            "Go to Dashboard",
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 10),
                      TextButton(
                        onPressed: _closeDialogs,
                        child: Text(
                          "Close",
                          style: TextStyle(
                            color: hintTextColor,
                            fontSize: isSmallScreen ? 13 : 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Error Dialog
          if (_showErrorDialog)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  width: screenWidth * 0.85,
                  padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: isSmallScreen ? 70 : 80,
                        height: isSmallScreen ? 70 : 80,
                        decoration: BoxDecoration(
                          color: errorColor.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.error_outline,
                          size: isSmallScreen ? 45 : 50,
                          color: errorColor,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 20),
                      Text(
                        "Error",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 20 : 22,
                          fontWeight: FontWeight.bold,
                          color: errorColor,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 10),
                      Text(
                        _errorMessage.isNotEmpty 
                            ? _errorMessage 
                            : "Something went wrong",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isSmallScreen ? 20 : 25),
                      SizedBox(
                        width: double.infinity,
                        height: isSmallScreen ? 45 : 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: errorColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _closeDialogs,
                          child: Text(
                            "Try Again",
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 10),
                      TextButton(
                        onPressed: _closeDialogs,
                        child: Text(
                          "Close",
                          style: TextStyle(
                            color: hintTextColor,
                            fontSize: isSmallScreen ? 13 : 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _submitLeave() async {
    if (!_formKey.currentState!.validate()) return;

    if (leaveType == null) {
      _showErrorPopup("Please select leave type");
      return;
    }

    final hasNet = await _hasInternet();
    if (!hasNet) {
      _showErrorPopup("No internet connection");
      return;
    }

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

    if (result["success"] == true) {
      _formKey.currentState!.reset();
      fromDateCtrl.clear();
      toDateCtrl.clear();
      reasonCtrl.clear();
      inchargeCtrl.clear();
      setState(() {
        leaveType = null;
        compOff = "NO";
      });
      
      await Future.delayed(const Duration(milliseconds: 300));
      _showSuccessPopup();
    } else {
      await Future.delayed(const Duration(milliseconds: 300));
      _showErrorPopup(result["message"]);
    }
  }

  @override
  void dispose() {
    fromDateCtrl.dispose();
    toDateCtrl.dispose();
    reasonCtrl.dispose();
    empCodeCtrl.dispose();
    empNameCtrl.dispose();
    inchargeCtrl.dispose();
    super.dispose();
  }
}