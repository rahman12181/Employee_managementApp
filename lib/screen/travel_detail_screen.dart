// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TravelDetailScreen extends StatelessWidget {
  final Map<String, dynamic> travelData;

  const TravelDetailScreen({super.key, required this.travelData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    
    double responsiveWidth(double percentage) => screenWidth * percentage;
    double responsiveHeight(double percentage) => screenHeight * percentage;
    double responsiveFontSize(double baseSize) => baseSize * (screenWidth / 375);

    final primaryColor = isDark ? Colors.blue[300]! : const Color(0xFF2563EB);
    final secondaryColor = isDark ? Colors.blue[400]! : const Color(0xFF3B82F6);
    final backgroundColor = isDark ? Colors.grey[900]! : const Color(0xFFF8FAFD);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];

    // Format date if available
    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return 'N/A';
      try {
        final date = DateTime.parse(dateStr);
        return DateFormat('dd MMM yyyy').format(date);
      } catch (e) {
        return dateStr;
      }
    }

    // Get status color
    Color getStatusColor(String status) {
      final statusLower = status.toLowerCase();
      if (statusLower.contains("approved")) return Colors.green;
      if (statusLower.contains("rejected")) return Colors.red;
      if (statusLower.contains("cancelled")) return Colors.grey;
      if (statusLower.contains("pending") ||
          statusLower.contains("draft") ||
          statusLower.contains("submitted")) {
        return Colors.orange;
      }
      return Colors.blue;
    }

    final status = travelData["status"] ?? travelData["workflow_state"] ?? "Pending";
    final statusColor = getStatusColor(status);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Animated Header
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: responsiveWidth(0.05),
                vertical: responsiveHeight(0.02),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(responsiveWidth(0.01)),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: responsiveWidth(0.05),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: responsiveWidth(0.03)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Travel Request",
                          style: TextStyle(
                            fontSize: responsiveFontSize(22),
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          travelData["employee_name"] ?? "Employee Name",
                          style: TextStyle(
                            fontSize: responsiveFontSize(14),
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(responsiveWidth(0.04)),
                child: Column(
                  children: [
                    // Status Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(responsiveWidth(0.04)),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(responsiveWidth(0.04)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(responsiveWidth(0.03)),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.info_rounded,
                              color: statusColor,
                              size: responsiveWidth(0.07),
                            ),
                          ),
                          SizedBox(width: responsiveWidth(0.04)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Current Status",
                                  style: TextStyle(
                                    fontSize: responsiveFontSize(12),
                                    color: subtitleColor,
                                  ),
                                ),
                                SizedBox(height: responsiveHeight(0.005)),
                                Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: responsiveFontSize(18),
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: responsiveHeight(0.025)),

                    // Request Details Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(responsiveWidth(0.04)),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(responsiveWidth(0.04)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(responsiveWidth(0.02)),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.description_rounded,
                                  color: primaryColor,
                                  size: responsiveWidth(0.06),
                                ),
                              ),
                              SizedBox(width: responsiveWidth(0.03)),
                              Text(
                                "Request Details",
                                style: TextStyle(
                                  fontSize: responsiveFontSize(16),
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: responsiveHeight(0.02)),
                          _buildDetailItem(
                            label: "Purpose of Travel",
                            value: travelData["purpose_of_travel"] ?? "N/A",
                            icon: Icons.travel_explore,
                            color: Colors.blue,
                            responsiveWidth: responsiveWidth,
                            responsiveFontSize: responsiveFontSize,
                          ),
                          _buildDivider(),
                          _buildDetailItem(
                            label: "Travel Type",
                            value: travelData["travel_type"] ?? "N/A",
                            icon: Icons.flight_takeoff,
                            color: Colors.orange,
                            responsiveWidth: responsiveWidth,
                            responsiveFontSize: responsiveFontSize,
                          ),
                          _buildDivider(),
                          _buildDetailItem(
                            label: "Travel Funding",
                            value: travelData["travel_funding"] ?? "N/A",
                            icon: Icons.account_balance_wallet,
                            color: Colors.green,
                            responsiveWidth: responsiveWidth,
                            responsiveFontSize: responsiveFontSize,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: responsiveHeight(0.025)),

                    // Date Information Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(responsiveWidth(0.04)),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(responsiveWidth(0.04)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(responsiveWidth(0.02)),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.calendar_month_rounded,
                                  color: Colors.purple,
                                  size: responsiveWidth(0.06),
                                ),
                              ),
                              SizedBox(width: responsiveWidth(0.03)),
                              Text(
                                "Date Information",
                                style: TextStyle(
                                  fontSize: responsiveFontSize(16),
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: responsiveHeight(0.02)),
                          _buildDetailItem(
                            label: "Created Date",
                            value: formatDate(travelData["creation"] ?? travelData["posting_date"]),
                            icon: Icons.edit_calendar,
                            color: Colors.purple,
                            responsiveWidth: responsiveWidth,
                            responsiveFontSize: responsiveFontSize,
                          ),
                          _buildDivider(),
                          _buildDetailItem(
                            label: "Posting Date",
                            value: formatDate(travelData["posting_date"]),
                            icon: Icons.post_add,
                            color: Colors.teal,
                            responsiveWidth: responsiveWidth,
                            responsiveFontSize: responsiveFontSize,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: responsiveHeight(0.025)),

                    // Reference Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(responsiveWidth(0.04)),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(responsiveWidth(0.04)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(responsiveWidth(0.02)),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.confirmation_number_rounded,
                                  color: Colors.amber,
                                  size: responsiveWidth(0.06),
                                ),
                              ),
                              SizedBox(width: responsiveWidth(0.03)),
                              Text(
                                "Reference Information",
                                style: TextStyle(
                                  fontSize: responsiveFontSize(16),
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: responsiveHeight(0.02)),
                          _buildDetailItem(
                            label: "Document ID",
                            value: travelData["name"] ?? "N/A",
                            icon: Icons.numbers,
                            color: Colors.amber,
                            responsiveWidth: responsiveWidth,
                            responsiveFontSize: responsiveFontSize,
                          ),
                          _buildDivider(),
                          _buildDetailItem(
                            label: "Employee ID",
                            value: travelData["employee"] ?? "N/A",
                            icon: Icons.badge,
                            color: Colors.cyan,
                            responsiveWidth: responsiveWidth,
                            responsiveFontSize: responsiveFontSize,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: responsiveHeight(0.03)),

                    // Close Button
                    SizedBox(
                      width: double.infinity,
                      height: responsiveHeight(0.065),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(responsiveWidth(0.03)),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          "Close",
                          style: TextStyle(
                            fontSize: responsiveFontSize(16),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: responsiveHeight(0.02)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required double Function(double) responsiveWidth,
    required double Function(double) responsiveFontSize,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: responsiveWidth(0.01)),
      child: Row(
        children: [
          Container(
            width: responsiveWidth(0.12),
            height: responsiveWidth(0.12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: responsiveWidth(0.05),
            ),
          ),
          SizedBox(width: responsiveWidth(0.03)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: responsiveFontSize(12),
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: responsiveWidth(0.01)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: responsiveFontSize(15),
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(
        height: 1,
        color: Colors.grey.withOpacity(0.3),
      ),
    );
  }
}