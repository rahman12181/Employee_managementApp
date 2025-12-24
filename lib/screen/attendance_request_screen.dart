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

  double responsiveWidth(double v) =>
      MediaQuery.of(context).size.width * v;

  double responsiveFontSize(double v) =>
      MediaQuery.of(context).size.width * (v / 375);

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: responsiveFontSize(14)),
      floatingLabelStyle: const TextStyle(color: Colors.black),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(responsiveWidth(0.04)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(responsiveWidth(0.04)),
        borderSide: const BorderSide(color: Colors.black),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(responsiveWidth(0.04)),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 52, 169, 232),
        ),
      ),
    );
  }

  Future<void> submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    try {
      await AttendanceRequestService().submitRequest(
        date: selectedDate,
        reason: reason,
        explanation: explanationCtrl.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Request submitted successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text("Attendance Request"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(responsiveWidth(0.05)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// DATE
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now()
                              .subtract(const Duration(days: 30)),
                          lastDate: DateTime.now(),
                          initialDate: selectedDate,
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: inputDecoration("Date"),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('dd MMM yyyy')
                                  .format(selectedDate),
                              style: TextStyle(
                                fontSize: responsiveFontSize(14),
                              ),
                            ),
                            const Icon(Icons.calendar_today, size: 18),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// REASON
                    DropdownButtonFormField<String>(
                      initialValue: reason,
                      decoration: inputDecoration("Reason"),
                      items: const [
                        DropdownMenuItem(
                            value: "On Duty", child: Text("On Duty")),
                        DropdownMenuItem(
                            value: "Missed Punch",
                            child: Text("Missed Punch")),
                        DropdownMenuItem(
                            value: "System Issue",
                            child: Text("System Issue")),
                      ],
                      onChanged: (val) => setState(() => reason = val!),
                    ),

                    const SizedBox(height: 16),

                    /// EXPLANATION
                    TextFormField(
                      controller: explanationCtrl,
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

                    const SizedBox(height: 24),

                    /// SUBMIT BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 52, 169, 232),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                responsiveWidth(0.04)),
                          ),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Submit Request",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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
