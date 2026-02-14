// ignore_for_file: deprecated_member_use, prefer_const_constructors, unused_local_variable

import 'package:flutter/material.dart';
import 'package:management_app/services/leave_balance_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class LeaveBalanceScreen extends StatefulWidget {
  const LeaveBalanceScreen({super.key});

  @override
  State<LeaveBalanceScreen> createState() => _LeaveBalanceScreenState();
}

class _LeaveBalanceScreenState extends State<LeaveBalanceScreen>
    with TickerProviderStateMixin {
  final LeaveBalanceService _leaveService = LeaveBalanceService();
  Map<String, double> _leaveBalances = {
    'Annual Leave': 0.0,
    'Sick Leave': 0.0,
  };
  bool _isLoading = true;
  String? _errorMessage;
  String? _employeeName;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final List<Map<String, dynamic>> _leaveTypes = [
    {
      'key': 'Annual Leave',
      'title': 'Annual Leave',
      'icon': Icons.beach_access,
      'color': Colors.green,
      'gradient': [const Color(0xFF43A047), const Color(0xFF66BB6A)],
    },
    {
      'key': 'Sick Leave',
      'title': 'Sick Leave',
      'icon': Icons.medical_services,
      'color': Colors.orange,
      'gradient': [const Color(0xFFFFA726), const Color(0xFFFFB74D)],
    },
    {
      'key': 'Casual Leave',
      'title': 'Casual Leave',
      'icon': Icons.free_breakfast,
      'color': Colors.blue,
      'gradient': [const Color(0xFF42A5F5), const Color(0xFF64B5F6)],
    },
    {
      'key': 'Compensatory Off',
      'title': 'Comp. Off',
      'icon': Icons.access_time,
      'color': Colors.purple,
      'gradient': [const Color(0xFFAB47BC), const Color(0xFFBA68C8)],
    },
  ];

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _testConnectionAndLoadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _testConnectionAndLoadData() async {
    await LeaveBalanceService.testCredentials();
    await _loadLeaveData();
  }

  Future<void> _loadLeaveData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      _employeeName = prefs.getString('employee_name') ?? 'Employee';
      
      final balances = await _leaveService.fetchLeaveBalances();
      
      if (mounted) {
        setState(() {
          _leaveBalances = balances;
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      debugPrint('Error loading leave data: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final height = media.size.height;
    final padding = media.padding;
    final safeTop = padding.top;
    final safeBottom = padding.bottom;
    
    // Responsive sizes
    final isSmallScreen = width < 360;
    final isTablet = width > 600;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isDark ? Colors.grey[900]! : Colors.white,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadLeaveData,
            color: theme.primaryColor,
            backgroundColor: isDark ? Colors.grey[800] : Colors.white,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // AppBar like Travel Request Screen
                SliverAppBar(
                  expandedHeight: height * 0.15,
                  floating: false,
                  pinned: true,
                  backgroundColor: isDark ? Colors.grey[900] : Colors.white,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: isDark ? Colors.white : Colors.grey[800],
                      size: width * 0.06,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: isDark ? Colors.white : Colors.grey[800],
                        size: width * 0.06,
                      ),
                      onPressed: _loadLeaveData,
                      tooltip: 'Refresh',
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: EdgeInsets.only(
                      left: width * 0.05,
                      bottom: height * 0.02,
                    ),
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Leave Balance',
                          style: TextStyle(
                            fontSize: isTablet ? 24 : 20,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.grey[900],
                          ),
                        ),
                        if (_employeeName != null)
                          Text(
                            _employeeName!,
                            style: TextStyle(
                              fontSize: isTablet ? 14 : 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [Colors.grey[900]!, Colors.grey[850]!]
                              : [Colors.white, Colors.grey[50]!],
                        ),
                      ),
                    ),
                  ),
                ),

                // Main Content
                SliverPadding(
                  padding: EdgeInsets.all(width * 0.04),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Welcome Card with Animation
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: _buildWelcomeCard(isDark, width, height, isTablet),
                        ),
                      ),

                      SizedBox(height: height * 0.025),

                      // Summary Header
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(width * 0.015),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(width * 0.015),
                                  ),
                                  child: Icon(
                                    Icons.analytics_rounded,
                                    color: theme.primaryColor,
                                    size: width * 0.045,
                                  ),
                                ),
                                SizedBox(width: width * 0.02),
                                Text(
                                  'Leave Summary',
                                  style: TextStyle(
                                    fontSize: isTablet ? 20 : 16,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : Colors.grey[900],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: width * 0.03,
                                vertical: height * 0.006,
                              ),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(width * 0.03),
                                border: Border.all(
                                  color: theme.primaryColor.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                '${DateTime.now().year}',
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: isTablet ? 14 : 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: height * 0.02),

                      // Loading State
                      if (_isLoading)
                        SizedBox(
                          height: height * 0.3,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: width * 0.1,
                                  height: width * 0.1,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                SizedBox(height: height * 0.015),
                                Text(
                                  'Fetching your leave balances...',
                                  style: TextStyle(
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    fontSize: isTablet ? 14 : 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Error State
                      if (_errorMessage != null && !_isLoading)
                        _buildErrorWidget(isDark, width, height, theme),

                      // Leave Cards Grid
                      if (!_isLoading && _errorMessage == null)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isTablet ? 4 : 2,
                            crossAxisSpacing: width * 0.03,
                            mainAxisSpacing: height * 0.015,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: _leaveTypes.length,
                          itemBuilder: (context, index) {
                            final leaveType = _leaveTypes[index];
                            final balance = _leaveBalances[leaveType['key']] ?? 0.0;
                            
                            return TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: Duration(milliseconds: 500 + (index * 100)),
                              curve: Curves.easeOutBack,
                              builder: (context, double value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: _buildLeaveCard(
                                    title: leaveType['title'],
                                    balance: balance,
                                    icon: leaveType['icon'],
                                    gradientColors: leaveType['gradient'],
                                    index: index,
                                    isDark: isDark,
                                    width: width,
                                    height: height,
                                  ),
                                );
                              },
                            );
                          },
                        ),

                      SizedBox(height: height * 0.02),

                      // Recent Activity Section
                      if (!_isLoading && _errorMessage == null)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(width * 0.015),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(width * 0.015),
                                    ),
                                    child: Icon(
                                      Icons.history_rounded,
                                      color: Colors.blue,
                                      size: width * 0.045,
                                    ),
                                  ),
                                  SizedBox(width: width * 0.02),
                                  Text(
                                    'Recent Activity',
                                    style: TextStyle(
                                      fontSize: isTablet ? 18 : 15,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : Colors.grey[900],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: height * 0.012),
                              _buildRecentActivityCard(isDark, width, height),
                            ],
                          ),
                        ),

                      SizedBox(height: height * 0.025),

                      // Bottom Info
                      if (!_isLoading && _errorMessage == null)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            padding: EdgeInsets.all(width * 0.035),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800]! : Colors.grey[100]!,
                              borderRadius: BorderRadius.circular(width * 0.03),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  size: width * 0.04,
                                ),
                                SizedBox(width: width * 0.02),
                                Expanded(
                                  child: Text(
                                    'Leave balances are updated automatically based on your attendance and leave requests.',
                                    style: TextStyle(
                                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                                      fontSize: isTablet ? 13 : 11,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Extra bottom padding
                      SizedBox(height: safeBottom > 0 ? safeBottom : height * 0.02),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(bool isDark, double width, double height, bool isTablet) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor,
            theme.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(width * 0.04),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: height * 0.003),
                Text(
                  _employeeName ?? 'Employee',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 22 : 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: height * 0.01),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.025,
                    vertical: height * 0.004,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(width * 0.04),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: width * 0.03,
                      ),
                      SizedBox(width: width * 0.01),
                      Text(
                        _getFormattedDate(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 13 : 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(width * 0.025),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.beach_access_rounded,
              color: Colors.white,
              size: width * 0.08,
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${now.day} ${months[now.month - 1]}, ${now.year}';
  }

  Widget _buildLeaveCard({
    required String title,
    required double balance,
    required IconData icon,
    required List<Color> gradientColors,
    required int index,
    required bool isDark,
    required double width,
    required double height,
  }) {
    final colors = [
      gradientColors.first,
      gradientColors.last,
    ];
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * 0.035),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            _showLeaveDetails(context, title, balance, icon, colors.first);
          },
          borderRadius: BorderRadius.circular(width * 0.035),
          child: Padding(
            padding: EdgeInsets.all(width * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(width * 0.015),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(width * 0.015),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: width * 0.05,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.015,
                        vertical: height * 0.002,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(width * 0.03),
                      ),
                      child: Text(
                        '${_getUsagePercentage(balance)}%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: width * 0.022,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: width * 0.03,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: height * 0.003),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      balance.toStringAsFixed(1),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.07,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: width * 0.005),
                    Padding(
                      padding: EdgeInsets.only(bottom: height * 0.006),
                      child: Text(
                        'days',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: width * 0.025,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.003),
                LinearProgressIndicator(
                  value: (balance / 30).clamp(0.0, 1.0),
                  backgroundColor: Colors.white.withOpacity(0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: height * 0.003,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard(bool isDark, double width, double height) {
    return Container(
      padding: EdgeInsets.all(width * 0.035),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(width * 0.035),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(width * 0.025),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_rounded,
              color: Colors.blue,
              size: width * 0.045,
            ),
          ),
          SizedBox(width: width * 0.025),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No recent activity',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.grey[900],
                    fontSize: width * 0.035,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: height * 0.002),
                Text(
                  'Your recent leave applications will appear here',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: width * 0.028,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(bool isDark, double width, double height, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width * 0.05),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(width * 0.04),
        border: Border.all(color: Colors.red.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(width * 0.03),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: Colors.red.shade700,
              size: width * 0.08,
            ),
          ),
          SizedBox(height: height * 0.015),
          Text(
            'Failed to Load Data',
            style: TextStyle(
              fontSize: width * 0.04,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.grey[900],
            ),
          ),
          SizedBox(height: height * 0.008),
          Text(
            _errorMessage ?? 'Unknown error occurred',
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize: width * 0.032,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: height * 0.02),
          SizedBox(
            width: width * 0.5,
            child: ElevatedButton.icon(
              onPressed: _loadLeaveData,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.03,
                  vertical: height * 0.012,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(width * 0.025),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bottom Sheet with Safe Area
  void _showLeaveDetails(BuildContext context, String title, double balance, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Container(
          padding: EdgeInsets.only(
            left: width * 0.05,
            right: width * 0.05,
            top: width * 0.05,
            bottom: bottomPadding > 0 ? bottomPadding : width * 0.05,
          ),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 35,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.grey[900],
                ),
              ),
              SizedBox(height: 6),
              Text(
                '${balance.toStringAsFixed(1)} days available',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  int _getUsagePercentage(double balance) {
    return ((balance / 30) * 100).round().clamp(0, 100);
  }
}