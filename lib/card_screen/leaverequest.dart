import 'package:flutter/material.dart';
import 'package:management_app/services/leave_request_service.dart';

class LeaveRequest extends StatefulWidget {
  const LeaveRequest({super.key});

  @override
  State<LeaveRequest> createState() => _LeaveRequestState();
}

class _LeaveRequestState extends State<LeaveRequest> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading=false;

  final TextEditingController fromDateCtrl = TextEditingController();
  final TextEditingController toDateCtrl = TextEditingController();
  final TextEditingController reasonCtrl = TextEditingController();
  final TextEditingController empCodeCtrl = TextEditingController();
  final TextEditingController empNameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();

  String? leaveType;
  String durationType = "FULL";
  String compOff = "NO";

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
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        title: const Text("Leave Request"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Leave Type",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
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

              const SizedBox(height: 16),

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
                  const SizedBox(width: 12),
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

              const SizedBox(height: 16),

              const Text(
                "Duration",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: ["FULL", "AN", "FN"].map((e) {
                  final isSelected = durationType == e;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => durationType = e),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.red : Colors.transparent,
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            e == "FULL" ? "Full day" : e,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              const Text(
                "Reason for leave",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 6),
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

              const SizedBox(height: 16),

              const Text(
                "Is it a Comp Off?",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: ["NO", "YES"].map((e) {
                  final isSelected = compOff == e;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => compOff = e),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.red : Colors.transparent,
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            e,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Employee Code",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  Text("Handover Duty", style: TextStyle(color: Colors.red)),
                ],
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: empCodeCtrl,
                decoration: InputDecoration(
                  hintText: "Employee Code",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// Employee Name
              const Text(
                "Employee Name",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: empNameCtrl,
                decoration: InputDecoration(
                  hintText: "Employee Name",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "Applicant's phone Number",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: "Phone Number",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) =>
                    value!.length < 10 ? "Enter valid number" : null,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    setState(() => _isLoading = true);

                    final result = await LeaveRequestService.submitLeave(
                      employeeCode: empCodeCtrl.text.trim(),
                      leaveType: LeaveRequestService.mapLeaveType(leaveType),
                      fromDate: fromDateCtrl.text,
                      toDate: toDateCtrl.text,
                      reason: reasonCtrl.text.trim(),
                      compOff: compOff,
                    );

                    setState(() => _isLoading = false);

                    if (result["success"] == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Leave applied successfully"),
                          backgroundColor: Colors.green,
                        ),
                      );

                      _formKey.currentState!.reset();
                      fromDateCtrl.clear();
                      toDateCtrl.clear();
                      reasonCtrl.clear();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result["message"]),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },

                  child: const Text(
                    "SUBMIT",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
