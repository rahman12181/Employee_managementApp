import 'package:flutter/material.dart';
import 'package:management_app/services/travel_request_service.dart';

class TravelRequestScreen extends StatefulWidget {
  const TravelRequestScreen({super.key});

  @override
  State<TravelRequestScreen> createState() => _TravelRequestScreenState();
}

class _TravelRequestScreenState extends State<TravelRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final fromCtrl = TextEditingController();
  final toCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  bool isLoading = false;

  String travelType = "International";
  String travelFunding = "Fully Sponsored";
  String purpose = "Annual Leave";
  String mode = "Flight";

  Future<void> pickDate() async {
    FocusScope.of(context).unfocus();

    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      dateCtrl.text =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} 10:00:00";
    }
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final message = await TravelRequestService.submitTravelRequest(
        travelType: travelType,
        travelFunding: travelFunding,
        purpose: purpose,
        from: fromCtrl.text.trim(),
        to: toCtrl.text.trim(),
        mode: mode,
        departureDate: dateCtrl.text.trim(),
        description: descCtrl.text.trim(),
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Success"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("OK"),
            )
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Error"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF1E88E5),
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Travel Request",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1565C0),
                  Color(0xFF1E88E5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Travel Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      DropdownButtonFormField<String>(
                        initialValue: travelType,
                        decoration:
                            _inputDecoration("Travel Type", Icons.public),
                        items: const [
                          DropdownMenuItem(
                              value: "International",
                              child: Text("International")),
                          DropdownMenuItem(
                              value: "Domestic", child: Text("Domestic")),
                        ],
                        onChanged: (v) => travelType = v!,
                      ),

                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: travelFunding,
                        decoration: _inputDecoration(
                          "Travel Funding",
                          Icons.account_balance_wallet,
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: "Fully Sponsored",
                              child: Text("Fully Sponsored")),
                          DropdownMenuItem(
                              value: "Self Sponsored",
                              child: Text("Self Sponsored")),
                        ],
                        onChanged: (v) => travelFunding = v!,
                      ),

                      const SizedBox(height: 14),
                      TextFormField(
                        controller: fromCtrl,
                        decoration: _inputDecoration(
                          "Travel From",
                          Icons.location_on,
                        ),
                        validator: (v) =>
                            v!.isEmpty ? "Required" : null,
                      ),

                      const SizedBox(height: 14),
                      TextFormField(
                        controller: toCtrl,
                        decoration:
                            _inputDecoration("Travel To", Icons.flag),
                        validator: (v) =>
                            v!.isEmpty ? "Required" : null,
                      ),

                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: mode,
                        decoration: _inputDecoration(
                          "Mode of Travel",
                          Icons.directions,
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: "Flight", child: Text("Flight")),
                          DropdownMenuItem(
                              value: "Train", child: Text("Train")),
                          DropdownMenuItem(
                              value: "Bus", child: Text("Bus")),
                        ],
                        onChanged: (v) => mode = v!,
                      ),

                      const SizedBox(height: 14),
                      TextFormField(
                        controller: dateCtrl,
                        readOnly: true,
                        onTap: pickDate,
                        decoration: _inputDecoration(
                          "Departure Date",
                          Icons.calendar_month,
                        ),
                        validator: (v) =>
                            v!.isEmpty ? "Required" : null,
                      ),

                      const SizedBox(height: 14),
                      TextFormField(
                        controller: descCtrl,
                        maxLines: 3,
                        decoration:
                            _inputDecoration("Description", Icons.notes),
                      ),

                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF1E88E5),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Submit Travel Request",
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
      ),
    );
  }
}
