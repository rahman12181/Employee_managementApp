// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/employee_advance_service.dart';

class AdvanceHistoryScreen extends StatefulWidget {
  const AdvanceHistoryScreen({super.key});

  @override
  State<AdvanceHistoryScreen> createState() => _AdvanceHistoryScreenState();
}

class _AdvanceHistoryScreenState extends State<AdvanceHistoryScreen>
    with SingleTickerProviderStateMixin {
  final EmployeeAdvanceService _advanceService = EmployeeAdvanceService();
  List<Map<String, dynamic>> _advances = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _selectedFilter = 'All';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    _loadAdvances();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAdvances() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final result = await _advanceService.getAppliedAdvances();
      if (result['success'] == true) {
        final data = result['data'] as List<dynamic>;
        setState(() {
          _advances = data.cast<Map<String, dynamic>>().toList();
          _isLoading = false;
        });
        _showSnackbar('Loaded ${_advances.length} advance(s)', Colors.green);
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        _showSnackbar(result['message'] ?? 'Failed to load advances', Colors.red);
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      _showSnackbar('Error: ${e.toString()}', Colors.red);
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.green ? Icons.check_circle_rounded : Icons.error_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF22C55E);
      case 'rejected':
        return const Color(0xFFEF4444);
      case 'pending':
        return const Color(0xFFF59E0B);
      default:
        return Colors.grey.shade500;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF22C55E).withOpacity(0.1);
      case 'rejected':
        return const Color(0xFFEF4444).withOpacity(0.1);
      case 'pending':
        return const Color(0xFFF59E0B).withOpacity(0.1);
      default:
        return Colors.grey.shade100;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'pending':
        return Icons.pending_rounded;
      default:
        return Icons.hourglass_empty_rounded;
    }
  }

  List<Map<String, dynamic>> get _filteredAdvances {
    if (_selectedFilter == 'All') return _advances;
    return _advances
        .where(
          (adv) => adv['status'].toString().toLowerCase() == _selectedFilter.toLowerCase(),
        )
        .toList();
  }

  double get _totalAmount {
    return _advances.fold(0, (sum, advance) {
      final amount = double.tryParse(advance['advance_amount']?.toString() ?? '0') ?? 0;
      return sum + amount;
    });
  }

  double get _approvedAmount {
    return _advances
        .where((a) => a['status'].toString().toLowerCase() == 'approved')
        .fold(0, (sum, advance) {
          final amount = double.tryParse(advance['advance_amount']?.toString() ?? '0') ?? 0;
          return sum + amount;
        });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade50 : Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            // Animated Header
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.018,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDarkMode
                          ? [Colors.blue.shade800, Colors.blue.shade900]
                          : [Colors.blue.shade600, Colors.blue.shade700],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade400.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Container(
                          padding: EdgeInsets.all(screenWidth * 0.01),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: screenWidth * 0.05,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Advance History',
                              style: TextStyle(
                                fontSize: screenWidth * 0.055,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Your salary advance requests',
                              style: TextStyle(
                                fontSize: screenWidth * 0.03,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                            size: screenWidth * 0.065,
                          ),
                          onPressed: _loadAdvances,
                          tooltip: 'Refresh',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Main Content
            Expanded(
              child: _isLoading
                  ? _buildLoadingState(screenWidth, screenHeight, theme)
                  : _hasError
                      ? _buildErrorState(screenWidth, screenHeight)
                      : _advances.isEmpty
                          ? _buildEmptyState(screenWidth, screenHeight, theme)
                          : _buildContent(screenWidth, screenHeight, isDarkMode, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(double screenWidth, double screenHeight, ThemeData theme) {
    return Center(
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 800),
        builder: (context, double value, child) {
          return Opacity(opacity: value, child: child);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: screenWidth * 0.15,
              height: screenWidth * 0.15,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.blue.shade600,
              ),
            ),
            SizedBox(height: screenHeight * 0.025),
            Text(
              'Loading your advances...',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                color: theme.hintColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              'Please wait a moment',
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: theme.hintColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(double screenWidth, double screenHeight) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.06),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.red.shade50, Colors.red.shade100],
                ),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: screenWidth * 0.15,
                color: Colors.red.shade600,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Text(
              'Failed to Load Data',
              style: TextStyle(
                fontSize: screenWidth * 0.055,
                fontWeight: FontWeight.w700,
                color: Colors.red.shade700,
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            Text(
              'We couldn\'t fetch your advance history.\nPlease check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            SizedBox(height: screenHeight * 0.035),
            ElevatedButton(
              onPressed: _loadAdvances,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08,
                  vertical: screenHeight * 0.018,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                ),
                elevation: 3,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, size: screenWidth * 0.045),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(double screenWidth, double screenHeight, ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.06),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.blue.shade50, Colors.blue.shade100],
                ),
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                size: screenWidth * 0.15,
                color: Colors.blue.shade600,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Text(
              'No Advances Yet',
              style: TextStyle(
                fontSize: screenWidth * 0.055,
                fontWeight: FontWeight.w700,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            Text(
              'You haven\'t applied for any salary advances.\nStart by requesting your first advance!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: theme.hintColor,
                height: 1.4,
              ),
            ),
            SizedBox(height: screenHeight * 0.035),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08,
                  vertical: screenHeight * 0.018,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                ),
                elevation: 3,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_circle_rounded, size: screenWidth * 0.045),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    'Request Advance',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    double screenWidth,
    double screenHeight,
    bool isDarkMode,
    ThemeData theme,
  ) {
    final approvedCount = _advances.where((a) => a['status'].toString().toLowerCase() == 'approved').length;
    final pendingCount = _advances.where((a) => a['status'].toString().toLowerCase() == 'pending').length;
    final rejectedCount = _advances.where((a) => a['status'].toString().toLowerCase() == 'rejected').length;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Stats Cards
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.02,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        title: 'Total Advances',
                        value: _advances.length.toString(),
                        icon: Icons.list_alt_rounded,
                        color: Colors.blue,
                        subtitle: '${_advances.length} Request${_advances.length != 1 ? 's' : ''}',
                        amount: _totalAmount,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: _buildStatCard(
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        title: 'Approved',
                        value: approvedCount.toString(),
                        icon: Icons.check_circle_rounded,
                        color: Colors.green,
                        subtitle: '$approvedCount Approved',
                        amount: _approvedAmount,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.015),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        title: 'Pending',
                        value: pendingCount.toString(),
                        icon: Icons.pending_rounded,
                        color: Colors.orange,
                        subtitle: pendingCount > 0 ? 'Awaiting review' : 'No pending',
                        amount: 0,
                        showAmount: false,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: _buildStatCard(
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        title: 'Rejected',
                        value: rejectedCount.toString(),
                        icon: Icons.cancel_rounded,
                        color: Colors.red,
                        subtitle: rejectedCount > 0 ? 'Not approved' : 'No rejections',
                        amount: 0,
                        showAmount: false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter Chips
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.01,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Approved', 'Pending', 'Rejected'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  final statusColor = _getStatusColor(filter);
                  
                  return Padding(
                    padding: EdgeInsets.only(right: screenWidth * 0.03),
                    child: FilterChip(
                      label: Text(
                        filter,
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? statusColor : theme.hintColor,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: _getStatusBgColor(filter),
                      checkmarkColor: statusColor,
                      onSelected: (selected) {
                        setState(() => _selectedFilter = selected ? filter : 'All');
                      },
                      backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                      side: BorderSide(
                        color: isSelected ? statusColor : Colors.transparent,
                        width: 1.5,
                      ),
                      showCheckmark: false,
                      avatar: isSelected
                          ? Icon(
                              _getStatusIcon(filter),
                              size: screenWidth * 0.04,
                              color: statusColor,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // List Header
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.01,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredAdvances.length} ${_filteredAdvances.length == 1 ? 'Request' : 'Requests'}',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenHeight * 0.005,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'SAR',
                        style: TextStyle(
                          fontSize: screenWidth * 0.032,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Icon(
                        Icons.arrow_downward_rounded,
                        size: screenWidth * 0.04,
                        color: Colors.blue.shade700,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: RefreshIndicator.adaptive(
              onRefresh: _loadAdvances,
              color: Colors.blue,
              backgroundColor: theme.cardColor,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.01,
                ),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _filteredAdvances.length,
                itemBuilder: (context, index) {
                  final advance = _filteredAdvances[index];
                  return TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: Duration(milliseconds: 500 + (index * 100)),
                    curve: Curves.easeOutCubic,
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: _buildAdvanceCard(
                      advance: advance,
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      isDarkMode: isDarkMode,
                      theme: theme,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required double screenWidth,
    required double screenHeight,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
    double amount = 0,
    bool showAmount = true,
  }) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.035),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(screenWidth * 0.025),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
            ),
            child: Icon(icon, color: color, size: screenWidth * 0.05),
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    if (showAmount && amount > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.02,
                          vertical: screenHeight * 0.003,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(screenWidth * 0.02),
                        ),
                        child: Text(
                          'SAR ${amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.028,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.003),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: screenWidth * 0.032,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: screenHeight * 0.002),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: screenWidth * 0.028,
                    color: Colors.grey.shade500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvanceCard({
    required Map<String, dynamic> advance,
    required double screenWidth,
    required double screenHeight,
    required bool isDarkMode,
    required ThemeData theme,
  }) {
    final amount = double.tryParse(advance['advance_amount']?.toString() ?? '0') ?? 0;
    final status = advance['status']?.toString() ?? 'Pending';
    final purpose = advance['purpose']?.toString() ?? 'No purpose specified';
    final date = advance['posting_date']?.toString() ?? '';
    final formattedDate = date.isNotEmpty
        ? DateFormat('dd MMM yyyy • hh:mm a').format(DateTime.parse(date))
        : 'Date not available';
    final paymentMode = advance['mode_of_payment']?.toString() ?? 'N/A';
    final currency = advance['currency']?.toString() ?? 'SAR';
    final statusColor = _getStatusColor(status);
    final statusBgColor = _getStatusBgColor(status);

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          onTap: () => _showAdvanceDetails(advance, screenWidth, screenHeight, theme),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.025),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getStatusIcon(status),
                        size: screenWidth * 0.045,
                        color: statusColor,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.003),
                          Text(
                            'ID: ${advance['name']?.toString() ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: screenWidth * 0.03,
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.025,
                        vertical: screenHeight * 0.005,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                      child: Text(
                        formattedDate.split(' • ')[0],
                        style: TextStyle(
                          fontSize: screenWidth * 0.028,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.015),

                // Amount and Purpose
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '$currency ',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.032,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                amount.toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: screenWidth * 0.06,
                                  fontWeight: FontWeight.w800,
                                  color: theme.textTheme.titleLarge?.color,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.008),
                          Text(
                            purpose,
                            style: TextStyle(
                              fontSize: screenWidth * 0.036,
                              color: theme.hintColor,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.03),
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.025),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade600],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade400.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        color: Colors.white,
                        size: screenWidth * 0.045,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.015),

                // Footer
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenHeight * 0.012,
                  ),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoChip(
                        screenWidth: screenWidth,
                        icon: Icons.payment_rounded,
                        label: paymentMode,
                        color: Colors.blue,
                      ),
                      _buildInfoChip(
                        screenWidth: screenWidth,
                        icon: Icons.account_balance_rounded,
                        label: advance['advance_account']?.toString().split(' - ').last ?? 'N/A',
                        color: Colors.purple,
                      ),
                      _buildInfoChip(
                        screenWidth: screenWidth,
                        icon: Icons.access_time_rounded,
                        label: DateFormat('hh:mm a').format(DateTime.parse(date)),
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required double screenWidth,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: screenWidth * 0.035,
          color: color,
        ),
        SizedBox(width: screenWidth * 0.01),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showAdvanceDetails(
    Map<String, dynamic> advance,
    double screenWidth,
    double screenHeight,
    ThemeData theme,
  ) {
    final amount = double.tryParse(advance['advance_amount']?.toString() ?? '0') ?? 0;
    final status = advance['status']?.toString() ?? 'Pending';
    final currency = advance['currency']?.toString() ?? 'SAR';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: EdgeInsets.only(top: screenHeight * 0.05),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
              width: screenWidth * 0.15,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getStatusBgColor(status),
                    ),
                    child: Icon(
                      _getStatusIcon(status),
                      color: _getStatusColor(status),
                      size: screenWidth * 0.07,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Advance Details',
                          style: TextStyle(
                            fontSize: screenWidth * 0.055,
                            fontWeight: FontWeight.w700,
                            color: theme.textTheme.titleLarge?.color,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          'ID: ${advance['name'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: theme.hintColor,
                      size: screenWidth * 0.06,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            Divider(height: screenHeight * 0.02, thickness: 1),
            
            // Details
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(screenWidth * 0.06),
                child: Column(
                  children: [
                    _buildDetailItem(
                      screenWidth: screenWidth,
                      label: 'Advance Amount',
                      value: '$currency ${amount.toStringAsFixed(2)}',
                      icon: Icons.currency_rupee_rounded,
                      color: Colors.blue,
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    _buildDetailItem(
                      screenWidth: screenWidth,
                      label: 'Status',
                      value: status,
                      icon: _getStatusIcon(status),
                      color: _getStatusColor(status),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    _buildDetailItem(
                      screenWidth: screenWidth,
                      label: 'Purpose',
                      value: advance['purpose']?.toString() ?? 'Not specified',
                      icon: Icons.description_rounded,
                      color: Colors.purple,
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    _buildDetailItem(
                      screenWidth: screenWidth,
                      label: 'Applied Date',
                      value: advance['posting_date']?.toString() ?? 'N/A',
                      icon: Icons.calendar_today_rounded,
                      color: Colors.green,
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    _buildDetailItem(
                      screenWidth: screenWidth,
                      label: 'Payment Mode',
                      value: advance['mode_of_payment']?.toString() ?? 'N/A',
                      icon: Icons.payment_rounded,
                      color: Colors.orange,
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    _buildDetailItem(
                      screenWidth: screenWidth,
                      label: 'Advance Account',
                      value: advance['advance_account']?.toString() ?? 'N/A',
                      icon: Icons.account_balance_rounded,
                      color: Colors.teal,
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    _buildDetailItem(
                      screenWidth: screenWidth,
                      label: 'Repay from Salary',
                      value: advance['repay_from_salary']?.toString() == '1' ? 'Yes' : 'No',
                      icon: Icons.account_balance_wallet_rounded,
                      color: Colors.amber,
                    ),
                  ],
                ),
              ),
            ),
            
            // Close Button
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.06),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required double screenWidth,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(screenWidth * 0.025),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
            ),
            child: Icon(icon, color: color, size: screenWidth * 0.05),
          ),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: screenWidth * 0.032,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}