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
          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
          title: Text(
            "Success",
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: isDarkMode ? Colors.grey[300] : Colors.black,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text(
                "OK",
                style: TextStyle(
                  color: isDarkMode ? Colors.blue[300] : Colors.blue,
                ),
              ),
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
          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
          title: Text(
            "Error",
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            e.toString(),
            style: TextStyle(
              color: isDarkMode ? Colors.grey[300] : Colors.black,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "OK",
                style: TextStyle(
                  color: isDarkMode ? Colors.blue[300] : Colors.blue,
                ),
              ),
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
      labelStyle: TextStyle(
        color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
      ),
      prefixIcon: Icon(
        icon,
        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
      ),
      filled: true,
      fillColor: isDarkMode ? Colors.grey[800] : Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.035),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.035),
        borderSide: BorderSide(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.035),
        borderSide: BorderSide(
          color: isDarkMode ? Colors.blue[300]! : const Color(0xFF1E88E5),
          width: 1.5,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.018,
      ),
    );
  }

  // Media query variables
  late double screenWidth;
  late double screenHeight;
  late bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final padding = MediaQuery.of(context).padding;

    final textColor = isDarkMode ? Colors.white : Colors.black;
    final cardColor = isDarkMode ? Colors.grey[800]! : Colors.white;
    final buttonColor = isDarkMode ? Colors.blue[300]! : const Color(0xFF1E88E5);
    final appBarGradientStart = isDarkMode ? Colors.grey[800]! : const Color(0xFF1565C0);
    final appBarGradientEnd = isDarkMode ? Colors.grey[700]! : const Color(0xFF1E88E5);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Travel Request",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.white,
            ),
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
          iconTheme: IconThemeData(
            color: isDarkMode ? Colors.white : Colors.white,
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
                borderRadius: BorderRadius.circular(screenWidth * 0.05),
              ),
              color: cardColor,
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Travel Details",
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      DropdownButtonFormField<String>(
                        dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                        style: TextStyle(
                          color: textColor,
                          fontSize: screenWidth * 0.038,
                        ),
                        decoration: _inputDecoration("Travel Type", Icons.public),
                        items: const [
                          DropdownMenuItem(
                            value: "International",
                            child: Text("International"),
                          ),
                          DropdownMenuItem(
                            value: "Domestic",
                            child: Text("Domestic"),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => travelType = v);
                          }
                        },
                      ),

                      SizedBox(height: screenHeight * 0.014),
                      DropdownButtonFormField<String>(
                        dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                        style: TextStyle(
                          color: textColor,
                          fontSize: screenWidth * 0.038,
                        ),
                        decoration: _inputDecoration(
                          "Travel Funding",
                          Icons.account_balance_wallet,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "Fully Sponsored",
                            child: Text("Fully Sponsored"),
                          ),
                          DropdownMenuItem(
                            value: "Self Sponsored",
                            child: Text("Self Sponsored"),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => travelFunding = v);
                          }
                        },
                      ),

                      SizedBox(height: screenHeight * 0.014),
                      TextFormField(
                        controller: fromCtrl,
                        style: TextStyle(
                          color: textColor,
                          fontSize: screenWidth * 0.038,
                        ),
                        decoration: _inputDecoration(
                          "Travel From",
                          Icons.location_on,
                        ),
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),

                      SizedBox(height: screenHeight * 0.014),
                      TextFormField(
                        controller: toCtrl,
                        style: TextStyle(
                          color: textColor,
                          fontSize: screenWidth * 0.038,
                        ),
                        decoration: _inputDecoration("Travel To", Icons.flag),
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),

                      SizedBox(height: screenHeight * 0.014),
                      DropdownButtonFormField<String>(
                        dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                        style: TextStyle(
                          color: textColor,
                          fontSize: screenWidth * 0.038,
                        ),
                        decoration: _inputDecoration(
                          "Mode of Travel",
                          Icons.directions,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "Flight",
                            child: Text("Flight"),
                          ),
                          DropdownMenuItem(
                            value: "Train",
                            child: Text("Train"),
                          ),
                          DropdownMenuItem(
                            value: "Bus",
                            child: Text("Bus"),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => mode = v);
                          }
                        },
                      ),

                      SizedBox(height: screenHeight * 0.014),
                      TextFormField(
                        controller: dateCtrl,
                        style: TextStyle(
                          color: textColor,
                          fontSize: screenWidth * 0.038,
                        ),
                        readOnly: true,
                        onTap: pickDate,
                        decoration: _inputDecoration(
                          "Departure Date",
                          Icons.calendar_month,
                        ),
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),

                      SizedBox(height: screenHeight * 0.014),
                      TextFormField(
                        controller: descCtrl,
                        style: TextStyle(
                          color: textColor,
                          fontSize: screenWidth * 0.038,
                        ),
                        maxLines: 3,
                        decoration: _inputDecoration("Description", Icons.notes),
                      ),

                      SizedBox(height: screenHeight * 0.03),
                      SizedBox(
                        width: double.infinity,
                        height: screenHeight * 0.065,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            elevation: isDarkMode ? 2 : 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(screenWidth * 0.035),
                            ),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  height: screenHeight * 0.025,
                                  width: screenHeight * 0.025,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  "Submit Travel Request",
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
      ),
    );
  }
}