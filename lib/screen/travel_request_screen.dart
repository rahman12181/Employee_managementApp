// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:management_app/services/travel_request_service.dart';
import 'package:flutter/services.dart';

class TravelRequestScreen extends StatefulWidget {
  const TravelRequestScreen({super.key});

  @override
  State<TravelRequestScreen> createState() => _TravelRequestScreenState();
}

class _TravelRequestScreenState extends State<TravelRequestScreen> 
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  final fromCtrl = TextEditingController();
  final toCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  bool isLoading = false;

  String travelType = "International";
  String travelFunding = "Fully Sponsored";
  String purpose = "Business";
  String mode = "Flight";

  // Options for dropdowns
  final List<Map<String, dynamic>> travelTypes = [
    {
      'value': 'International',
      'label': 'International',
      'icon': Icons.public,
      'color': Colors.blue
    },
    {
      'value': 'Domestic',
      'label': 'Domestic',
      'icon': Icons.home,
      'color': Colors.green
    },
  ];

  final List<Map<String, dynamic>> fundingTypes = [
    {
      'value': 'Fully Sponsored',
      'label': 'Fully Sponsored',
      'icon': Icons.account_balance_wallet,
      'color': Colors.purple
    },
    {
      'value': 'Self Sponsored',
      'label': 'Self Sponsored',
      'icon': Icons.person,
      'color': Colors.orange
    },
    {
      'value': 'Partially Sponsored',
      'label': 'Partially Sponsored',
      'icon': Icons.account_balance,
      'color': Colors.teal
    },
  ];

  final List<Map<String, dynamic>> travelModes = [
    {
      'value': 'Flight',
      'label': 'Flight',
      'icon': Icons.airplanemode_active,
      'color': Colors.red
    },
    {
      'value': 'Train',
      'label': 'Train',
      'icon': Icons.train,
      'color': Colors.blue
    },
    {
      'value': 'Bus',
      'label': 'Bus',
      'icon': Icons.directions_bus,
      'color': Colors.green
    },
    {
      'value': 'Car',
      'label': 'Car',
      'icon': Icons.directions_car,
      'color': Colors.orange
    },
  ];

  final List<Map<String, dynamic>> purposeTypes = [
    {
      'value': 'Business',
      'label': 'Business Meeting',
      'icon': Icons.business,
      'color': Colors.blue
    },
    {
      'value': 'Conference',
      'label': 'Conference',
      'icon': Icons.groups,
      'color': Colors.purple
    },
    {
      'value': 'Training',
      'label': 'Training',
      'icon': Icons.school,
      'color': Colors.green
    },
    {
      'value': 'Project',
      'label': 'Project Work',
      'icon': Icons.work,
      'color': Colors.orange
    },
    {
      'value': 'Personal',
      'label': 'Personal',
      'icon': Icons.person,
      'color': Colors.red
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: isDarkMode ? Colors.black : Colors.white,
        systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );
  }

  Future<void> pickDate() async {
    HapticFeedback.selectionClick();
    FocusScope.of(context).unfocus();

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final primaryColor = isDarkMode ? Colors.blue[300]! : const Color(0xFF2563EB);

    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: isDarkMode ? Colors.grey[800]! : Colors.white,
              onSurface: isDarkMode ? Colors.white : Colors.black,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: isDarkMode ? Colors.grey[800]! : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      dateCtrl.text =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }

    HapticFeedback.mediumImpact();
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

      // Show success dialog
      await _showSuccessDialog(message);
      
    } catch (e) {
      if (!mounted) return;

      // Show error dialog
      await _showErrorDialog(e.toString());
      
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _showSuccessDialog(String message) async {
    final width = MediaQuery.of(context).size.width;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? Colors.grey[800]! : Colors.white;
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: width * 0.85,
          padding: EdgeInsets.all(width * 0.05),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(width * 0.06),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: width * 0.2,
                height: width * 0.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withOpacity(0.1),
                  border: Border.all(color: Colors.green, width: 3),
                ),
                child: Icon(
                  Icons.check,
                  size: width * 0.1,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: width * 0.05),
              Text(
                "Success!",
                style: TextStyle(
                  fontSize: width * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: width * 0.03),
              Text(
                message,
                style: TextStyle(
                  fontSize: width * 0.04,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: width * 0.05),
              SizedBox(
                width: double.infinity,
                height: width * 0.12,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width * 0.03),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text(
                    "OK",
                    style: TextStyle(
                      fontSize: width * 0.04,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

  Future<void> _showErrorDialog(String error) async {
    final width = MediaQuery.of(context).size.width;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? Colors.grey[800]! : Colors.white;
    
    await showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: width * 0.85,
          padding: EdgeInsets.all(width * 0.05),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(width * 0.06),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: width * 0.2,
                height: width * 0.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(0.1),
                  border: Border.all(color: Colors.red, width: 3),
                ),
                child: Icon(
                  Icons.error_outline,
                  size: width * 0.1,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: width * 0.05),
              Text(
                "Error",
                style: TextStyle(
                  fontSize: width * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: width * 0.03),
              Text(
                error,
                style: TextStyle(
                  fontSize: width * 0.04,
                  color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: width * 0.05),
              SizedBox(
                width: double.infinity,
                height: width * 0.12,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width * 0.03),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: Text(
                    "OK",
                    style: TextStyle(
                      fontSize: width * 0.04,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: width * 0.035,
        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: TextStyle(
        color: isDarkMode ? Colors.blue[300]! : const Color(0xFF2563EB),
        fontSize: width * 0.035,
        fontWeight: FontWeight.w600,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: width * 0.04,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(width * 0.03),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(width * 0.03),
        borderSide: BorderSide(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(width * 0.03),
        borderSide: BorderSide(
          color: isDarkMode ? Colors.blue[400]! : const Color(0xFF2563EB),
          width: 2.0,
        ),
      ),
      filled: true,
      fillColor: isDarkMode ? Colors.grey[800]! : Colors.grey[50]!,
      prefixIcon: icon != null
          ? Icon(
              icon,
              size: width * 0.05,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            )
          : null,
      prefixIconColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
      suffixIcon: label.contains("Date")
          ? Icon(
              Icons.calendar_today_rounded,
              size: width * 0.05,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            )
          : null,
    );
  }

  Widget _buildSelectionChips(
    String title,
    String currentValue,
    List<Map<String, dynamic>> options,
    Function(String) onChanged,
  ) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: width * 0.04,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        SizedBox(height: height * 0.01),
        Wrap(
          spacing: width * 0.02,
          runSpacing: height * 0.01,
          children: options.map((option) {
            final isSelected = currentValue == option['value'];
            final optionColor = option['color'] as Color;
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    option['icon'] as IconData,
                    size: width * 0.045,
                    color: isSelected ? Colors.white : optionColor,
                  ),
                  SizedBox(width: width * 0.02),
                  Text(
                    option['label'],
                    style: TextStyle(
                      fontSize: width * 0.035,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  HapticFeedback.selectionClick();
                  onChanged(option['value']);
                }
              },
              backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
              selectedColor: optionColor,
              side: BorderSide(
                color: isSelected
                    ? optionColor
                    : isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(width * 0.025),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: height * 0.012,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    fromCtrl.dispose();
    toCtrl.dispose();
    dateCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey[900]! : const Color(0xFFF8FAFD);
    final primaryColor = isDarkMode ? Colors.blue[300]! : const Color(0xFF2563EB);
    final secondaryColor = isDarkMode ? Colors.blue[400]! : const Color(0xFF3B82F6);
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final shadowColor = isDarkMode
        ? Colors.black.withOpacity(0.5)
        : Colors.blueGrey.withOpacity(0.1);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isDarkMode ? Colors.black : Colors.white,
        systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Stack(
              children: [
                SafeArea(
                  bottom: false,
                  child: Container(
                    color: backgroundColor,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Container(
                        color: backgroundColor,
                        width: width,
                        child: Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: Column(
                              children: [
                                // Header Section
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.04,
                                    vertical: height * 0.02,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        primaryColor,
                                        secondaryColor,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(width * 0.08),
                                      bottomRight: Radius.circular(width * 0.08),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: shadowColor,
                                        blurRadius: 20,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          IconButton(
                                            onPressed: () => Navigator.pop(context),
                                            icon: Icon(
                                              Icons.arrow_back_rounded,
                                              color: Colors.white,
                                              size: width * 0.06,
                                            ),
                                          ),
                                          Text(
                                            "Travel Request",
                                            style: TextStyle(
                                              fontSize: width * 0.05,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          SizedBox(width: width * 0.06),
                                        ],
                                      ),
                                      SizedBox(height: height * 0.01),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: width * 0.04,
                                          vertical: height * 0.015,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(width * 0.03),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.flight_takeoff,
                                              color: Colors.white,
                                              size: width * 0.06,
                                            ),
                                            SizedBox(width: width * 0.03),
                                            Expanded(
                                              child: Text(
                                                "Fill in your travel details to submit a request",
                                                style: TextStyle(
                                                  fontSize: width * 0.04,
                                                  color: Colors.white.withOpacity(0.9),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Main Form
                                Container(
                                  color: backgroundColor,
                                  child: Card(
                                    elevation: 0,
                                    margin: EdgeInsets.all(width * 0.04),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(width * 0.05),
                                    ),
                                    color: cardColor,
                                    child: Padding(
                                      padding: EdgeInsets.all(width * 0.04),
                                      child: Form(
                                        key: _formKey,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Travel Type
                                            _buildSelectionChips(
                                              "Travel Type",
                                              travelType,
                                              travelTypes,
                                              (value) => setState(() => travelType = value),
                                            ),

                                            SizedBox(height: height * 0.025),

                                            // Travel Funding
                                            _buildSelectionChips(
                                              "Travel Funding",
                                              travelFunding,
                                              fundingTypes,
                                              (value) => setState(() => travelFunding = value),
                                            ),

                                            SizedBox(height: height * 0.025),

                                            // Purpose
                                            _buildSelectionChips(
                                              "Purpose of Travel",
                                              purpose,
                                              purposeTypes,
                                              (value) => setState(() => purpose = value),
                                            ),

                                            SizedBox(height: height * 0.025),

                                            // From and To Locations
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "From Location",
                                                        style: TextStyle(
                                                          fontSize: width * 0.04,
                                                          fontWeight: FontWeight.w600,
                                                          color: textColor,
                                                        ),
                                                      ),
                                                      SizedBox(height: height * 0.01),
                                                      TextFormField(
                                                        controller: fromCtrl,
                                                        style: TextStyle(
                                                          fontSize: width * 0.04,
                                                          color: textColor,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                        decoration: _inputDecoration(
                                                          "City, Country",
                                                          icon: Icons.location_on,
                                                        ),
                                                        validator: (v) => v!.isEmpty ? "Required" : null,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(width: width * 0.03),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "To Location",
                                                        style: TextStyle(
                                                          fontSize: width * 0.04,
                                                          fontWeight: FontWeight.w600,
                                                          color: textColor,
                                                        ),
                                                      ),
                                                      SizedBox(height: height * 0.01),
                                                      TextFormField(
                                                        controller: toCtrl,
                                                        style: TextStyle(
                                                          fontSize: width * 0.04,
                                                          color: textColor,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                        decoration: _inputDecoration(
                                                          "City, Country",
                                                          icon: Icons.flag,
                                                        ),
                                                        validator: (v) => v!.isEmpty ? "Required" : null,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(height: height * 0.025),

                                            // Travel Mode
                                            _buildSelectionChips(
                                              "Mode of Travel",
                                              mode,
                                              travelModes,
                                              (value) => setState(() => mode = value),
                                            ),

                                            SizedBox(height: height * 0.025),

                                            // Departure Date
                                            Text(
                                              "Departure Date",
                                              style: TextStyle(
                                                fontSize: width * 0.04,
                                                fontWeight: FontWeight.w600,
                                                color: textColor,
                                              ),
                                            ),
                                            SizedBox(height: height * 0.01),
                                            TextFormField(
                                              controller: dateCtrl,
                                              readOnly: true,
                                              onTap: pickDate,
                                              style: TextStyle(
                                                fontSize: width * 0.04,
                                                color: textColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              decoration: _inputDecoration(
                                                "Select departure date",
                                                icon: Icons.calendar_month,
                                              ),
                                              validator: (v) => v!.isEmpty ? "Required" : null,
                                            ),

                                            SizedBox(height: height * 0.025),

                                            // Description
                                            Text(
                                              "Additional Details",
                                              style: TextStyle(
                                                fontSize: width * 0.04,
                                                fontWeight: FontWeight.w600,
                                                color: textColor,
                                              ),
                                            ),
                                            SizedBox(height: height * 0.01),
                                            TextFormField(
                                              controller: descCtrl,
                                              style: TextStyle(
                                                fontSize: width * 0.04,
                                                color: textColor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 4,
                                              minLines: 3,
                                              decoration: _inputDecoration(
                                                "Enter any additional details or requirements...",
                                                icon: Icons.notes,
                                              ),
                                            ),

                                            SizedBox(height: height * 0.04),

                                            // Submit Button
                                            SizedBox(
                                              width: double.infinity,
                                              height: height * 0.065,
                                              child: ElevatedButton(
                                                onPressed: isLoading ? null : submit,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: primaryColor,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(width * 0.035),
                                                  ),
                                                  elevation: 0,
                                                  shadowColor: Colors.transparent,
                                                ),
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    AnimatedOpacity(
                                                      opacity: isLoading ? 0 : 1,
                                                      duration: const Duration(milliseconds: 200),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(
                                                            Icons.flight_takeoff_rounded,
                                                            size: width * 0.05,
                                                            color: Colors.white,
                                                          ),
                                                          SizedBox(width: width * 0.02),
                                                          Text(
                                                            "Submit Travel Request",
                                                            style: TextStyle(
                                                              fontSize: width * 0.04,
                                                              fontWeight: FontWeight.w700,
                                                              color: Colors.white,
                                                              letterSpacing: 0.5,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    if (isLoading)
                                                      SizedBox(
                                                        width: width * 0.06,
                                                        height: width * 0.06,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 3,
                                                          color: Colors.white,
                                                          backgroundColor: Colors.white.withOpacity(0.3),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),

                                            SizedBox(height: height * 0.02),

                                            // Cancel Button
                                            SizedBox(
                                              width: double.infinity,
                                              height: height * 0.055,
                                              child: TextButton(
                                                onPressed: isLoading
                                                    ? null
                                                    : () {
                                                        HapticFeedback.lightImpact();
                                                        Navigator.pop(context);
                                                      },
                                                style: TextButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(width * 0.035),
                                                  ),
                                                  foregroundColor: subtitleColor,
                                                ),
                                                child: Text(
                                                  "Cancel",
                                                  style: TextStyle(
                                                    fontSize: width * 0.04,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            // Info Note
                                            Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.all(width * 0.04),
                                              margin: EdgeInsets.only(top: height * 0.02),
                                              decoration: BoxDecoration(
                                                color: primaryColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(width * 0.03),
                                                border: Border.all(
                                                  color: primaryColor.withOpacity(0.2),
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.info_outline_rounded,
                                                    size: width * 0.05,
                                                    color: primaryColor,
                                                  ),
                                                  SizedBox(width: width * 0.03),
                                                  Expanded(
                                                    child: Text(
                                                      "Your travel request will be reviewed by the management team",
                                                      style: TextStyle(
                                                        fontSize: width * 0.035,
                                                        color: textColor,
                                                        fontWeight: FontWeight.w500,
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
              ],
            );
          },
        ),
      ),
    );
  }
}