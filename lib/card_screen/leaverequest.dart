// ignore_for_file: deprecated_member_use

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
  String _successMessage = "";

  final TextEditingController fromDateCtrl = TextEditingController();
  final TextEditingController toDateCtrl = TextEditingController();
  final TextEditingController reasonCtrl = TextEditingController();
  final TextEditingController empCodeCtrl = TextEditingController();
  final TextEditingController empNameCtrl = TextEditingController();
  final TextEditingController inchargeCtrl = TextEditingController();

  String? selectedLeaveType;
  String compOff = "NO";

  // Available leave types
  final List<Map<String, String>> leaveTypes = [
    {"code": "CL", "name": "Casual Leave"},
    {"code": "SL", "name": "Sick Leave"},
    {"code": "EL", "name": "Earned Leave"},
    {"code": "UL", "name": "Unpaid Leave"},
  ];

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  Future<void> _loadEmployeeData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmpCode = prefs.getString("employeeId") ?? "";
    final profileData = prefs.getString("profileData");
    
    setState(() {
      empCodeCtrl.text = savedEmpCode;
    });
    
    if (profileData != null) {
      try {
        final data = jsonDecode(profileData);
        final fullName = data["full_name"] ?? "";
        setState(() {
          empNameCtrl.text = fullName;
        });
      } catch (e) {
        print("Error parsing profile data: $e");
      }
    }
  }

  Future<void> selectDate(TextEditingController controller) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
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

  void _showSuccessPopup(String message) {
    setState(() {
      _successMessage = message;
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
      _successMessage = "";
      _errorMessage = "";
    });
  }

  void _navigateToDashboard() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    fromDateCtrl.clear();
    toDateCtrl.clear();
    reasonCtrl.clear();
    inchargeCtrl.clear();
    setState(() {
      selectedLeaveType = null;
      compOff = "NO";
    });
  }

  Future<void> _submitLeave() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedLeaveType == null) {
      _showErrorPopup("Please select leave type");
      return;
    }

    // Check internet connection
    final hasNet = await _hasInternet();
    if (!hasNet) {
      _showErrorPopup("No internet connection. Please check your connection and try again.");
      return;
    }

    // Validate dates
    try {
      final fromParts = fromDateCtrl.text.split("-");
      final toParts = toDateCtrl.text.split("-");
      
      if (fromParts.length != 3 || toParts.length != 3) {
        _showErrorPopup("Invalid date format. Please use DD-MM-YYYY format.");
        return;
      }
      
      final fromDate = DateTime(
        int.parse(fromParts[2]),
        int.parse(fromParts[1]),
        int.parse(fromParts[0]),
      );
      final toDate = DateTime(
        int.parse(toParts[2]),
        int.parse(toParts[1]),
        int.parse(toParts[0]),
      );
      
      if (toDate.isBefore(fromDate)) {
        _showErrorPopup("To date cannot be before from date.");
        return;
      }
      
      final difference = toDate.difference(fromDate).inDays;
      if (difference < 0) {
        _showErrorPopup("Invalid date range.");
        return;
      }
    } catch (e) {
      _showErrorPopup("Invalid date format. Please use DD-MM-YYYY format.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Call the service to submit leave
      final result = await LeaveRequestService.submitLeave(
        employeeCode: empCodeCtrl.text.trim(),
        leaveType: LeaveRequestService.mapLeaveType(selectedLeaveType),
        fromDate: fromDateCtrl.text,
        toDate: toDateCtrl.text,
        reason: reasonCtrl.text.trim(),
        compOff: compOff,
        inchargeReplacement: inchargeCtrl.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      if (result["success"] == true) {
        // Success - show success message
        final successMsg = result["message"] ?? "Leave applied successfully!";
        
        String displayMessage = successMsg;
        
        // Reset form on success
        _resetForm();
        
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Show success dialog with appropriate message
        _showSuccessPopup(displayMessage);
        
      } else {
        // Error - show error message
        await Future.delayed(const Duration(milliseconds: 300));
        _showErrorPopup(result["message"] ?? "Failed to apply leave. Please try again.");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      await Future.delayed(const Duration(milliseconds: 300));
      _showErrorPopup("An error occurred: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isDarkMode = mediaQuery.platformBrightness == Brightness.dark;
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isSmallScreen = screenWidth < 360;
    final paddingValue = isSmallScreen ? 12.0 : 16.0;

    // Theme colors
    final backgroundColor = isDarkMode ? Colors.grey[900]! : const Color(0xffF5F6FA);
    final cardColor = isDarkMode ? Colors.grey[800]! : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final hintTextColor = isDarkMode ? Colors.grey[400] : Colors.black54;
    final borderColor = isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
    final buttonColor = Theme.of(context).primaryColor;
    const successColor = Colors.green;
    const errorColor = Colors.red;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Leave Request",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
                  // Employee Info (Read-only)
                  if (empNameCtrl.text.isNotEmpty)
                    Card(
                      color: cardColor,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: borderColor),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Employee",
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: hintTextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              empNameCtrl.text,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "ID: ${empCodeCtrl.text}",
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: hintTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  SizedBox(height: screenHeight * 0.02),

                  // Leave Type
                  Text(
                    "Leave Type *",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: hintTextColor,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  DropdownButtonFormField<String>(
                    value: selectedLeaveType,
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
                    items: leaveTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type["code"],
                        child: Text(type["name"]!),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => selectedLeaveType = value),
                    validator: (value) =>
                        value == null ? "Please select leave type" : null,
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Date Range
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "From Date *",
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: hintTextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextFormField(
                              controller: fromDateCtrl,
                              readOnly: true,
                              onTap: () => selectDate(fromDateCtrl),
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                hintText: "DD-MM-YYYY",
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
                                  value!.isEmpty ? "Please select from date" : null,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "To Date *",
                              style: TextStyle(
                                fontSize: isSmallScreen ? 12 : 14,
                                color: hintTextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextFormField(
                              controller: toDateCtrl,
                              readOnly: true,
                              onTap: () => selectDate(toDateCtrl),
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                hintText: "DD-MM-YYYY",
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
                                  value!.isEmpty ? "Please select to date" : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Reason
                  Text(
                    "Reason for Leave *",
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
                    minLines: 3,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: "Enter reason for leave...",
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
                        value!.isEmpty ? "Please enter reason for leave" : null,
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Comp Off
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

                  // Incharge Replacement
                  Text(
                    "Incharge Replacement *",
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
                      hintText: "Enter incharge replacement name",
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
                    validator: (value) => value!.isEmpty ? "Please enter incharge replacement" : null,
                  ),

                  SizedBox(height: screenHeight * 0.04),

                  // Submit Button
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
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: _isLoading ? null : _submitLeave,
                      child: _isLoading
                          ? SizedBox(
                              width: isSmallScreen ? 18 : 20,
                              height: isSmallScreen ? 18 : 20,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              "SUBMIT LEAVE APPLICATION",
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.02),
                  
                  // Info note
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50]!.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: isSmallScreen ? 16 : 18, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Leave will be sent to your manager for approval",
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 13,
                              color: Colors.blue[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: isSmallScreen ? 40 : 50,
                        height: isSmallScreen ? 40 : 50,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: buttonColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Submitting Leave...",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Please wait",
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: hintTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Success Dialog
          if (_showSuccessDialog)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  width: screenWidth * 0.85,
                  padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
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
                          color: successColor.withOpacity(0.1),
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
                        _successMessage,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: textColor,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isSmallScreen ? 20 : 25),
                      SizedBox(
                        width: double.infinity,
                        height: isSmallScreen ? 45 : 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: successColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
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
                          "Apply Another Leave",
                          style: TextStyle(
                            color: buttonColor,
                            fontSize: isSmallScreen ? 13 : 14,
                            fontWeight: FontWeight.w500,
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
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  width: screenWidth * 0.85,
                  padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
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
                          color: errorColor.withOpacity(0.1),
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
                        _errorMessage,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: textColor,
                          height: 1.4,
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
                            elevation: 2,
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
                          "Cancel",
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