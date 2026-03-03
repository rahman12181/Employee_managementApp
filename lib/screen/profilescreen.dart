// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:management_app/services/profile_service.dart';
import 'package:management_app/services/auth_service.dart'; // ✅ Added import
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<Profilescreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  String? _errorMessage;

  // Sky Blue Color Palette
  static const Color skyBlue = Color(0xFF87CEEB);
  static const Color lightSky = Color(0xFFE0F2FE);
  static const Color mediumSky = Color(0xFF7EC8E0);
  static const Color deepSky = Color(0xFF00A5E0);
  static const Color offWhite = Color(0xFFF8FAFC);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color charcoal = Color(0xFF1E293B);
  static const Color slate = Color(0xFF334155);
  static const Color steel = Color(0xFF475569);

  List<Color> _getHeaderGradientColors(bool isDarkMode) {
    return isDarkMode
        ? [charcoal, slate, const Color(0xFF1E1E2E)]
        : [skyBlue, mediumSky, deepSky];
  }
  
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
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    _loadProfileData();
  }

  // 🔥 FIXED: Load profile using USER EMAIL
  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // ✅ Get userEmail instead of employeeId
      final userEmail = prefs.getString('userEmail') ?? prefs.getString('email');
      
      print("📱 User Email from SharedPreferences: $userEmail");
      
      if (userEmail != null && userEmail.isNotEmpty) {
        // ✅ Call User API (not Employee API)
        final result = await ProfileService.getUserProfile(userEmail);
        
        print("📦 API Result: $result");
        
        if (mounted) {
          if (result['success'] == true) {
            setState(() {
              _profileData = result['data'];
              _isLoading = false;
            });
            _animationController.forward();
          } else {
            setState(() {
              _errorMessage = result['message'];
              _isLoading = false;
            });
          }
        }
      } else {
        setState(() {
          _errorMessage = "User email not found. Please login again.";
          _isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Error: $e");
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // 🔥 Helper method to get profile image URL with authentication
  String? _getProfileImageUrl() {
    if (_profileData == null) {
      return null;
    }

    // Try full_image_url first (constructed in service)
    if (_profileData!['full_image_url'] != null && 
        _profileData!['full_image_url'].toString().isNotEmpty) {
      print("🖼️ Using full_image_url: ${_profileData!['full_image_url']}");
      return _profileData!['full_image_url'].toString();
    }
    
    // Try user_image field (from API)
    if (_profileData!['user_image'] != null && 
        _profileData!['user_image'].toString().isNotEmpty) {
      String imagePath = _profileData!['user_image'].toString();
      
      if (!imagePath.startsWith('http')) {
        String fullUrl = "https://ppecon.erpnext.com$imagePath";
        print("🖼️ Using constructed URL: $fullUrl");
        return fullUrl;
      } else {
        print("🖼️ Using direct URL: $imagePath");
        return imagePath;
      }
    }
    
    // Fallback to default image
    print("🖼️ No image found, using default");
    return null;
  }

  // Helper to get full name
  String _getFullName() {
    if (_profileData == null) return 'N/A';
    
    // Try full_name first
    if (_profileData!['full_name'] != null && _profileData!['full_name'].toString().isNotEmpty) {
      return _profileData!['full_name'].toString();
    }
    
    // Try employee_name (from old data)
    if (_profileData!['employee_name'] != null && _profileData!['employee_name'].toString().isNotEmpty) {
      return _profileData!['employee_name'].toString();
    }
    
    // Construct from first/last name
    String name = '';
    if (_profileData!['first_name'] != null) {
      name += _profileData!['first_name'].toString();
    }
    if (_profileData!['last_name'] != null && _profileData!['last_name'].toString().isNotEmpty) {
      name += ' ${_profileData!['last_name']}';
    }
    return name.isNotEmpty ? name : 'N/A';
  }

  Future<void> _refreshProfile() async {
    _animationController.reset();
    await _loadProfileData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildShimmerLoader() {
    final width = MediaQuery.of(context).size.width;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: width * 0.3,
            height: width * 0.3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: skyBlue.withOpacity(0.1),
            ),
          ),
          SizedBox(height: width * 0.05),
          Container(
            width: width * 0.5,
            height: width * 0.05,
            decoration: BoxDecoration(
              color: skyBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: width * 0.02),
          Container(
            width: width * 0.4,
            height: width * 0.04,
            decoration: BoxDecoration(
              color: skyBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: width * 0.08),
          ...List.generate(5, (index) => Padding(
            padding: EdgeInsets.only(bottom: width * 0.03),
            child: Container(
              width: double.infinity,
              height: width * 0.15,
              decoration: BoxDecoration(
                color: skyBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(width * 0.03),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    final width = MediaQuery.of(context).size.width;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(width * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(width * 0.05),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFF556270)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded, size: width * 0.1, color: Colors.white),
            ),
            SizedBox(height: width * 0.05),
            Text('Oops!', style: TextStyle(fontSize: width * 0.06, fontWeight: FontWeight.bold, color: Colors.red)),
            SizedBox(height: width * 0.02),
            Text(_errorMessage ?? 'Something went wrong', textAlign: TextAlign.center),
            SizedBox(height: width * 0.05),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _refreshProfile,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: width * 0.03),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [skyBlue, deepSky]),
                    borderRadius: BorderRadius.circular(width * 0.03),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded, color: Colors.white, size: width * 0.05),
                      SizedBox(width: width * 0.02),
                      Text('Try Again', style: TextStyle(color: Colors.white, fontSize: width * 0.04)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final width = MediaQuery.of(context).size.width;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: isDarkMode ? slate.withOpacity(0.5) : pureWhite,
        borderRadius: BorderRadius.circular(width * 0.04),
        border: Border.all(color: skyBlue.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: skyBlue.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(width * 0.02),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(width * 0.02),
              border: Border.all(color: color.withOpacity(0.3), width: 1),
            ),
            child: Icon(icon, size: width * 0.05, color: color),
          ),
          SizedBox(width: width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: width * 0.03, color: Colors.grey[600], fontWeight: FontWeight.w600)),
                SizedBox(height: width * 0.01),
                Text(value, style: TextStyle(fontSize: width * 0.04, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    final width = MediaQuery.of(context).size.width;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: width * 0.02, vertical: width * 0.01),
      decoration: BoxDecoration(color: skyBlue.withOpacity(0.05), borderRadius: BorderRadius.circular(width * 0.04)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(width * 0.015),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [skyBlue, deepSky]),
              borderRadius: BorderRadius.circular(width * 0.02),
              boxShadow: [
                BoxShadow(color: skyBlue.withOpacity(0.2), blurRadius: 10, spreadRadius: 1),
              ],
            ),
            child: Icon(icon, size: width * 0.04, color: Colors.white),
          ),
          SizedBox(width: width * 0.02),
          Text(title, style: TextStyle(fontSize: width * 0.045, fontWeight: FontWeight.w800, color: skyBlue)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = _getHeaderGradientColors(isDarkMode);
    
    final backgroundColor = isDarkMode ? charcoal : offWhite;
    final cardColor = isDarkMode ? slate : pureWhite;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: gradientColors.first,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: isDarkMode ? charcoal : pureWhite,
        systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          top: true,
          bottom: true,
          child: RefreshIndicator(
            onRefresh: _refreshProfile,
            color: skyBlue,
            backgroundColor: cardColor,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Premium Gradient App Bar
                SliverAppBar(
                  expandedHeight: height * 0.15,
                  floating: true,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: skyBlue.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: -height * 0.05,
                          right: -width * 0.1,
                          child: Container(
                            width: width * 0.5,
                            height: width * 0.5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.05),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -height * 0.03,
                          left: -width * 0.1,
                          child: Container(
                            width: width * 0.4,
                            height: width * 0.4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withOpacity(0.15),
                                  Colors.white.withOpacity(0.02),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        FlexibleSpaceBar(
                          centerTitle: true,
                          title: Padding(
                            padding: EdgeInsets.only(top: height * 0.02),
                            child: Text(
                              "My Profile",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: width * 0.06,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  leading: IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(width * 0.02),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                      ),
                      child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: width * 0.05),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    Container(
                      margin: EdgeInsets.only(right: width * 0.02),
                      child: IconButton(
                        icon: Container(
                          padding: EdgeInsets.all(width * 0.02),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                          ),
                          child: Icon(Icons.refresh_rounded, color: Colors.white, size: width * 0.05),
                        ),
                        onPressed: _refreshProfile,
                      ),
                    ),
                  ],
                ),

                // Main Content
                SliverPadding(
                  padding: EdgeInsets.all(width * 0.04),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      if (_isLoading)
                        SizedBox(height: height * 0.7, child: _buildShimmerLoader())
                      else if (_errorMessage != null)
                        SizedBox(height: height * 0.7, child: _buildErrorWidget())
                      else if (_profileData != null)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              children: [
                                // Profile Header
                                Container(
                                  padding: EdgeInsets.all(width * 0.05),
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? slate.withOpacity(0.5) : pureWhite,
                                    borderRadius: BorderRadius.circular(width * 0.06),
                                    border: Border.all(color: skyBlue.withOpacity(0.2), width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: skyBlue.withOpacity(0.1),
                                        blurRadius: 25,
                                        spreadRadius: 5,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      // Profile Image - FIXED SECTION
                                      Center(
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: width * 0.3,
                                              height: width * 0.3,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: LinearGradient(
                                                  colors: gradientColors,
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: skyBlue.withOpacity(0.3),
                                                    blurRadius: 20,
                                                    spreadRadius: 5,
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(3),
                                                child: ClipOval(
                                                  child: _getProfileImageUrl() != null
                                                      ? Image.network(
                                                          _getProfileImageUrl()!,
                                                          headers: {
                                                            "Cookie": AuthService.cookies.join("; "),
                                                          },
                                                          width: width * 0.3,
                                                          height: width * 0.3,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (context, error, stackTrace) {
                                                            print("❌ Image loading error: $error");
                                                            return Container(
                                                              color: Colors.grey[300],
                                                              child: Icon(
                                                                Icons.person,
                                                                size: width * 0.1,
                                                                color: Colors.grey[600],
                                                              ),
                                                            );
                                                          },
                                                        )
                                                      : Container(
                                                          color: Colors.grey[300],
                                                          child: Icon(
                                                            Icons.person,
                                                            size: width * 0.1,
                                                            color: Colors.grey[600],
                                                          ),
                                                        ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: Container(
                                                padding: EdgeInsets.all(width * 0.02),
                                                decoration: BoxDecoration(
                                                  color: ProfileService.getStatusColor(_profileData!['status'] ?? 'active'),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: cardColor, width: 3),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: ProfileService.getStatusColor(_profileData!['status'] ?? 'active').withOpacity(0.3),
                                                      blurRadius: 10,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                                child: Icon(
                                                  ProfileService.getStatusIcon(_profileData!['status'] ?? 'active'),
                                                  size: width * 0.04,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: width * 0.04),
                                      
                                      // Name
                                      Text(
                                        _getFullName(),
                                        style: TextStyle(
                                          fontSize: width * 0.06,
                                          fontWeight: FontWeight.bold,
                                          color: skyBlue,
                                        ),
                                      ),
                                      SizedBox(height: width * 0.01),
                                      
                                      // Email
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: width * 0.02),
                                        decoration: BoxDecoration(
                                          color: skyBlue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(width * 0.04),
                                          border: Border.all(color: skyBlue.withOpacity(0.3), width: 1),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.email_rounded, size: width * 0.04, color: skyBlue),
                                            SizedBox(width: width * 0.02),
                                            Flexible(
                                              child: Text(
                                                _profileData!['email'] ?? 'N/A',
                                                style: TextStyle(fontSize: width * 0.035, color: skyBlue, fontWeight: FontWeight.w700),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: width * 0.04),

                                // Personal Information
                                _buildSectionTitle('Personal Information', Icons.person_rounded, skyBlue),
                                SizedBox(height: width * 0.03),
                                
                                _buildInfoCard(
                                  label: 'Gender',
                                  value: _profileData!['gender'] ?? 'N/A',
                                  icon: Icons.wc_rounded,
                                  color: skyBlue,
                                ),
                                SizedBox(height: width * 0.02),
                                
                                _buildInfoCard(
                                  label: 'Date of Birth',
                                  value: '${ProfileService.formatDate(_profileData!['birth_date'] ?? _profileData!['date_of_birth'])} (${ProfileService.getAge(_profileData!['birth_date'] ?? _profileData!['date_of_birth'])} years)',
                                  icon: Icons.cake_rounded,
                                  color: deepSky,
                                ),
                                SizedBox(height: width * 0.02),
                                
                                _buildInfoCard(
                                  label: 'Blood Group',
                                  value: _profileData!['blood_group'] ?? 'N/A',
                                  icon: Icons.bloodtype_rounded,
                                  color: mediumSky,
                                ),
                                
                                SizedBox(height: width * 0.04),

                                // Contact Information
                                _buildSectionTitle('Contact Information', Icons.contact_phone_rounded, deepSky),
                                SizedBox(height: width * 0.03),
                                
                                _buildInfoCard(
                                  label: 'Mobile Number',
                                  value: _profileData!['phone'] ?? _profileData!['cell_number'] ?? 'N/A',
                                  icon: Icons.phone_android_rounded,
                                  color: Colors.green,
                                ),
                                SizedBox(height: width * 0.02),
                                
                                _buildInfoCard(
                                  label: 'Email',
                                  value: _profileData!['email'] ?? _profileData!['company_email'] ?? 'N/A',
                                  icon: Icons.email_rounded,
                                  color: skyBlue,
                                ),
                                
                                SizedBox(height: width * 0.04),

                                // Work Information
                                _buildSectionTitle('Work Information', Icons.work_rounded, skyBlue),
                                SizedBox(height: width * 0.03),
                                
                                _buildInfoCard(
                                  label: 'Department',
                                  value: _profileData!['department'] ?? 'N/A',
                                  icon: Icons.business_center_rounded,
                                  color: deepSky,
                                ),
                                SizedBox(height: width * 0.02),
                                
                                _buildInfoCard(
                                  label: 'Branch',
                                  value: _profileData!['branch'] ?? 'N/A',
                                  icon: Icons.location_city_rounded,
                                  color: mediumSky,
                                ),
                                SizedBox(height: width * 0.02),
                                
                                _buildInfoCard(
                                  label: 'Date of Joining',
                                  value: ProfileService.formatDate(_profileData!['date_of_joining']),
                                  icon: Icons.work_history_rounded,
                                  color: skyBlue,
                                ),

                                SizedBox(height: width * 0.1),
                              ],
                            ),
                          ),
                        ),
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
}