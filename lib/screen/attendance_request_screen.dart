import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/attendance_request_service.dart';

class AttendanceRequestScreen extends StatefulWidget {
  const AttendanceRequestScreen({super.key});

  @override
  State<AttendanceRequestScreen> createState() =>
      _AttendanceRequestScreenState();
}

class _AttendanceRequestScreenState extends State<AttendanceRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime selectedDate = DateTime.now();
  final TextEditingController explanationCtrl = TextEditingController();

  String reason = "On Duty";
  bool isSubmitting = false;

  late double screenWidth;
  late double screenHeight;
  late bool isDarkMode;

  double responsiveWidth(double v) => screenWidth * v;

  double responsiveFontSize(double v) => screenWidth * (v / 375);

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: responsiveFontSize(14),
        color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
      ),
      floatingLabelStyle: TextStyle(
        color: isDarkMode ? Colors.blue[300] : Colors.black,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.018,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(responsiveWidth(0.04)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(responsiveWidth(0.04)),
        borderSide: BorderSide(
          color: isDarkMode ? Colors.grey[700]! : Colors.black,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(responsiveWidth(0.04)),
        borderSide: BorderSide(
          color: isDarkMode ? Colors.blue[300]! : const Color.fromARGB(255, 52, 169, 232),
        ),
      ),
      filled: true,
      fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
    );
  }

  Future<void> submitRequest() async {
    if (!_formKey.currentState!.validate() || isSubmitting) return;

    setState(() => isSubmitting = true);

    try {
      await AttendanceRequestService().submitRequest(
        date: selectedDate,
        reason: reason,
        explanation: explanationCtrl.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Attendance request submitted successfully"),
          backgroundColor: isDarkMode ? Colors.green[800]! : Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceAll("Exception:", "").trim();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.isEmpty ? "Request failed" : message),
          backgroundColor: isDarkMode ? Colors.red[800]! : Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final padding = MediaQuery.of(context).padding;

    // Dark mode colors
    final backgroundColor = isDarkMode ? Colors.grey[900]! : const Color(0xFFF7F9FC);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final cardColor = isDarkMode ? Colors.grey[800]! : Colors.white;
    final buttonColor = isDarkMode ? Colors.blue[300]! : Colors.blue;
    final appBarGradientStart = isDarkMode ? Colors.grey[800]! : const Color(0xFF1565C0);
    final appBarGradientEnd = isDarkMode ? Colors.grey[700]! : const Color(0xFF1E88E5);
    final dropdownTextColor = isDarkMode ? Colors.white : Colors.black;
    final iconColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final dateTextColor = isDarkMode ? Colors.grey[300] : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "Attendance Request",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.white,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [appBarGradientStart, appBarGradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            screenWidth * 0.04,
            padding.top + screenHeight * 0.01,
            screenWidth * 0.04,
            screenHeight * 0.02,
          ),
          child: Card(
            elevation: isDarkMode ? 2 : 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsiveWidth(0.05)),
            ),
            color: cardColor,
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.045),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now(),
                          initialDate: selectedDate,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: isDarkMode ? Colors.blue[300]! : Colors.blue,
                                  onPrimary: Colors.white,
                                  surface: isDarkMode ? Colors.grey[800]! : Colors.white,
                                  onSurface: isDarkMode ? Colors.white : Colors.black,
                                ),
                                dialogBackgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: inputDecoration("Date").copyWith(
                          suffixIcon: Icon(
                            Icons.calendar_today,
                            size: screenWidth * 0.05,
                            color: iconColor,
                          ),
                        ),
                        child: Text(
                          DateFormat('dd MMM yyyy').format(selectedDate),
                          style: TextStyle(
                            fontSize: responsiveFontSize(14),
                            color: dateTextColor,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.016),

                    DropdownButtonFormField<String>(
                      dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: iconColor,
                        size: screenWidth * 0.06,
                      ),
                      style: TextStyle(
                        fontSize: responsiveFontSize(14),
                        color: dropdownTextColor,
                      ),
                      decoration: inputDecoration("Reason"),
                      items: const [
                        DropdownMenuItem(
                          value: "On Duty",
                          child: Text("On Duty"),
                        ),
                        DropdownMenuItem(
                          value: "Missed Punch",
                          child: Text("Missed Punch"),
                        ),
                        DropdownMenuItem(
                          value: "System Issue",
                          child: Text("System Issue"),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => reason = val);
                        }
                      },
                    ),

                    SizedBox(height: screenHeight * 0.016),

                    TextFormField(
                      controller: explanationCtrl,
                      style: TextStyle(
                        fontSize: responsiveFontSize(14),
                        color: textColor,
                      ),
                      maxLines: 4,
                      decoration: inputDecoration("Explanation"),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return "Explanation is required";
                        }
                        if (v.trim().length < 10) {
                          return "Minimum 10 characters required";
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: screenHeight * 0.024),

                    SizedBox(
                      width: double.infinity,
                      height: screenHeight * 0.065,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(responsiveWidth(0.04)),
                          ),
                        ),
                        child: isSubmitting
                            ? SizedBox(
                                width: screenWidth * 0.06,
                                height: screenWidth * 0.06,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                "Submit Request",
                                style: TextStyle(
                                  fontSize: screenWidth * 0.04,
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
          ),
        ),
      ),
    );
  }
}