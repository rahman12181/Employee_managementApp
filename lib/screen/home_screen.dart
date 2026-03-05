// lib/screen/home_screen.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:management_app/screen/homemain_screen.dart';
import 'package:management_app/screen/attendance_screen.dart';
import 'package:management_app/screen/dashboard_screen.dart';
import 'package:management_app/screen/setting_screen.dart';
import 'package:provider/provider.dart';
import 'package:management_app/providers/slide_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  
  late AnimationController _hintController;
  late Animation<double> _hintAnimation;
  late AnimationController _navBarController;
  
  late PageController _pageController;

  static final List<Widget> _bottomNavigationScreens = [
    const HomemainScreen(),
    const DashboardScreen(),
    const AttendanceScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    
    _hintController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _hintAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _hintController,
        curve: Curves.easeInOut,
      ),
    );
    
    _navBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _hintController.repeat(reverse: true);
    _navBarController.forward();
    
    _pageController = PageController(initialPage: _selectedIndex);
  }
  
  @override
  void dispose() {
    _hintController.dispose();
    _navBarController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final slideProvider = Provider.of<SlideProvider>(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Main Content - PageView
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: const BouncingScrollPhysics(),
            children: _bottomNavigationScreens,
          ),
          
          // ==================== UNIQUE & RESPONSIVE BOTTOM NAVIGATION ====================
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildUniqueBottomNavigation(isDarkMode, bottomPadding, screenWidth, screenHeight),
          ),
          
          // ==================== SLIDE BUTTON ====================
          if (slideProvider.showSlideToPunch)
            Positioned(
              left: 0,
              right: 0,
              bottom: bottomPadding + 10,
              child: _buildSlideToContinueButton(slideProvider, isDarkMode, screenWidth),
            ),
        ],
      ),
    );
  }

  // ==================== UNIQUE & RESPONSIVE BOTTOM NAVIGATION ====================
  Widget _buildUniqueBottomNavigation(bool isDarkMode, double bottomPadding, double screenWidth, double screenHeight) {
    final theme = Theme.of(context);
    
    // Responsive sizes based on screen width
    final double navBarHeight = screenWidth < 360 ? 56 : 64;
    final double iconSize = screenWidth < 360 ? 22 : 24;
    final double fontSize = screenWidth < 360 ? 10 : 11;
    final double activeIndicatorHeight = screenWidth < 360 ? 3 : 4;
    
    return Container(
      height: navBarHeight + bottomPadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode 
              ? [
                 const Color(0xFF334155), // Darker for dark mode
                  const Color(0xFF334155),
                ]
              : [
                  Colors.white,
                  Colors.grey.shade50,
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(isDarkMode ? 0.2 : 0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, -5),
          ),
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.5)
                : Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(screenWidth < 400 ? 20 : 30),
          topRight: Radius.circular(screenWidth < 400 ? 20 : 30),
        ),
        border: Border(
          top: BorderSide(
            color: theme.primaryColor.withOpacity(isDarkMode ? 0.3 : 0.2),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildUniqueNavItem(
              icon: Icons.home_rounded,
              activeIcon: Icons.home_rounded,
              label: "Home",
              index: 0,
              isDarkMode: isDarkMode,
              iconSize: iconSize,
              fontSize: fontSize,
              activeIndicatorHeight: activeIndicatorHeight,
              screenWidth: screenWidth,
            ),
            _buildUniqueNavItem(
              icon: Icons.dashboard_outlined,
              activeIcon: Icons.dashboard_rounded,
              label: "Dashboard",
              index: 1,
              isDarkMode: isDarkMode,
              iconSize: iconSize,
              fontSize: fontSize,
              activeIndicatorHeight: activeIndicatorHeight,
              screenWidth: screenWidth,
            ),
            _buildUniqueNavItem(
              icon: Icons.calendar_month_outlined,
              activeIcon: Icons.calendar_month_rounded,
              label: "History",
              index: 2,
              isDarkMode: isDarkMode,
              iconSize: iconSize,
              fontSize: fontSize,
              activeIndicatorHeight: activeIndicatorHeight,
              screenWidth: screenWidth,
            ),
            _buildUniqueNavItem(
              icon: Icons.settings_outlined,
              activeIcon: Icons.settings_rounded,
              label: "Setting",
              index: 3,
              isDarkMode: isDarkMode,
              iconSize: iconSize,
              fontSize: fontSize,
              activeIndicatorHeight: activeIndicatorHeight,
              screenWidth: screenWidth,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUniqueNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isDarkMode,
    required double iconSize,
    required double fontSize,
    required double activeIndicatorHeight,
    required double screenWidth,
  }) {
    final bool active = _selectedIndex == index;
    final theme = Theme.of(context);
    
    // Dark mode colors
    final Color inactiveColor = isDarkMode 
        ? Colors.grey.shade500 
        : Colors.grey.shade600;
    final Color activeColor = theme.primaryColor;
    final Color textColor = isDarkMode 
        ? Colors.grey.shade300 
        : Colors.grey.shade800;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          height: 56,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Main content
              Positioned.fill(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon with animation
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.elasticOut,
                      transform: Matrix4.identity()
                        ..scale(active ? 1.1 : 1.0),
                      child: Icon(
                        active ? activeIcon : icon,
                        size: iconSize,
                        color: active ? activeColor : inactiveColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Label with animation
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active ? activeColor : textColor,
                        letterSpacing: active ? 0.3 : 0,
                      ),
                      child: Text(label),
                    ),
                  ],
                ),
              ),
              
              // Active indicator
              if (active)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      height: activeIndicatorHeight,
                      width: screenWidth * 0.12,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            activeColor.withOpacity(0.5),
                            activeColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(activeIndicatorHeight / 2),
                        boxShadow: [
                          BoxShadow(
                            color: activeColor.withOpacity(isDarkMode ? 0.5 : 0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
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

  // ==================== SLIDE BUTTON - RESPONSIVE WITH DARK MODE ====================
  Widget _buildSlideToContinueButton(SlideProvider slideProvider, bool isDarkMode, double screenWidth) {
    final bool isTablet = screenWidth > 600;
    final double horizontalMargin = isTablet ? screenWidth * 0.2 : 16;
    final double buttonHeight = isTablet ? 60 : 50;
    final theme = Theme.of(context);
    
    // Dark mode colors for slide button background
    final List<Color> gradientColors = isDarkMode
        ? [
            const Color(0xFF2C2C2C),
            const Color(0xFF1E1E1E),
          ]
        : [
            Colors.white,
            Colors.grey[50]!,
          ];
    
    return Align(
      alignment: Alignment.bottomCenter,
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutBack,
        builder: (context, double value, child) {
          return Transform.scale(
            scale: value,
            child: Container(
              margin: EdgeInsets.fromLTRB(horizontalMargin, 0, horizontalMargin, 16),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                borderRadius: BorderRadius.circular(buttonHeight / 2),
                boxShadow: [
                  BoxShadow(
                    color: (slideProvider.isPunchInMode ? Colors.blue : Colors.red)
                        .withOpacity(isDarkMode ? 0.4 : 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: isDarkMode 
                        ? Colors.black.withOpacity(0.5)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: (slideProvider.isPunchInMode ? Colors.blue : Colors.red)
                      .withOpacity(isDarkMode ? 0.4 : 0.3),
                  width: 1.5,
                ),
              ),
              child: _buildSlideButton(slideProvider, isDarkMode, buttonHeight, screenWidth),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlideButton(SlideProvider slideProvider, bool isDarkMode, double buttonHeight, double screenWidth) {
    final bool isTablet = screenWidth > 600;
    final double sideButtonSize = isTablet ? 48 : 40;
    final double spacing = isTablet ? 16 : 12;
    final theme = Theme.of(context);
    
    return SizedBox(
      height: buttonHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double sliderWidth =
              constraints.maxWidth - (sideButtonSize * 2) - (spacing * 2);

          return Row(
            children: [
              // Close button with dark mode support
              _buildCircularButton(
                onTap: slideProvider.hideSlideButton,
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [
                          Colors.grey[600]!,
                          Colors.grey[700]!,
                        ]
                      : [
                          Colors.grey[700]!,
                          Colors.grey[800]!,
                        ],
                ),
                size: sideButtonSize,
                child: Icon(
                  Icons.close_rounded,
                  color: isDarkMode ? Colors.grey.shade300 : Colors.white70,
                  size: 20,
                ),
              ),

              SizedBox(width: spacing),

              // Slider
              Expanded(
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (slideProvider.slideProgress == 0) {
                      _hintController.stop();
                    }
                    
                    final double dragAmount = details.primaryDelta!;
                    final double newProgress = 
                        (slideProvider.slideProgress + (dragAmount / sliderWidth))
                            .clamp(0.0, 1.0);
                    
                    slideProvider.updateSlideProgress(newProgress);
                  },
                  onHorizontalDragEnd: (_) {
                    if (slideProvider.slideProgress >= 0.8) {
                      slideProvider.completePunch();
                      _hintController.repeat(reverse: true);
                    } else {
                      slideProvider.updateSlideProgress(0.0);
                      _hintController.repeat(reverse: true);
                    }
                  },
                  child: Container(
                    height: buttonHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDarkMode
                            ? [
                                Colors.grey[800]!,
                                Colors.grey[900]!,
                              ]
                            : [
                                Colors.grey[200]!,
                                Colors.grey[300]!,
                              ],
                      ),
                      borderRadius: BorderRadius.circular(buttonHeight / 2),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode 
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // Progress fill
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          width: sliderWidth * slideProvider.slideProgress,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: slideProvider.isPunchInMode
                                  ? [Colors.blue.shade400, Colors.blue.shade600]
                                  : [Colors.red.shade400, Colors.red.shade600],
                            ),
                            borderRadius: BorderRadius.circular(buttonHeight / 2),
                            boxShadow: [
                              BoxShadow(
                                color: (slideProvider.isPunchInMode ? Colors.blue : Colors.red)
                                    .withOpacity(isDarkMode ? 0.4 : 0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),

                        // Sliding button
                        Positioned(
                          left: (sliderWidth - buttonHeight) * slideProvider.slideProgress,
                          child: AnimatedBuilder(
                            animation: _hintAnimation,
                            builder: (context, child) {
                              final double extraOffset = 
                                  slideProvider.slideProgress == 0 
                                      ? _hintAnimation.value 
                                      : 0;
                              
                              return Transform.translate(
                                offset: Offset(extraOffset, 0),
                                child: Container(
                                  width: buttonHeight,
                                  height: buttonHeight,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isDarkMode
                                          ? [
                                              Colors.grey[300]!,
                                              Colors.grey[400]!,
                                            ]
                                          : [
                                              Colors.white,
                                              Colors.grey[100]!,
                                            ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: isDarkMode 
                                            ? Colors.black.withOpacity(0.4)
                                            : Colors.black.withOpacity(0.2),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                      BoxShadow(
                                        color: (slideProvider.isPunchInMode ? Colors.blue : Colors.red)
                                            .withOpacity(isDarkMode ? 0.5 : 0.4),
                                        blurRadius: 12,
                                        spreadRadius: slideProvider.slideProgress == 0 ? 2 : 0,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    slideProvider.isPunchInMode
                                        ? Icons.login_rounded
                                        : Icons.logout_rounded,
                                    color: slideProvider.isPunchInMode
                                        ? Colors.blue.shade600
                                        : Colors.red.shade600,
                                    size: buttonHeight * 0.5,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Center text (responsive) with dark mode support
                        Center(
                          child: Opacity(
                            opacity: 1 - slideProvider.slideProgress.clamp(0.0, 0.5),
                            child: isTablet 
                                ? _buildSlideTextDesktop(slideProvider, isDarkMode, buttonHeight)
                                : _buildSlideTextMobile(slideProvider, isDarkMode),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: spacing),

              // Check button with dark mode support
              AnimatedOpacity(
                opacity: slideProvider.slideProgress > 0.7 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: _buildCircularButton(
                  onTap: () {},
                  gradient: LinearGradient(
                    colors: slideProvider.isPunchInMode
                        ? [Colors.blue.shade400, Colors.blue.shade600]
                        : [Colors.red.shade400, Colors.red.shade600],
                  ),
                  size: sideButtonSize,
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper method for circular buttons with dark mode support
  Widget _buildCircularButton({
    required VoidCallback onTap,
    required Gradient gradient,
    required double size,
    required Widget child,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: gradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: isDarkMode 
                    ? Colors.black.withOpacity(0.5)
                    : Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // Mobile slide text with dark mode support
  Widget _buildSlideTextMobile(SlideProvider slideProvider, bool isDarkMode) {
    final Color textColor = isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600;
    final Color iconColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _hintAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_hintAnimation.value, 0),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: iconColor,
                size: 14,
              ),
            );
          },
        ),
        
        const SizedBox(width: 8),
        
        Icon(
          slideProvider.isPunchInMode
              ? Icons.login_rounded
              : Icons.logout_rounded,
          color: iconColor,
          size: 18,
        ),
        
        const SizedBox(width: 8),
        
        Text(
          slideProvider.isPunchInMode
              ? "Slide to Punch In"
              : "Slide to Punch Out",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 12,
            letterSpacing: 0.3,
          ),
        ),
        
        const SizedBox(width: 8),
        
        AnimatedBuilder(
          animation: _hintAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(-_hintAnimation.value, 0),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: iconColor,
                size: 14,
              ),
            );
          },
        ),
      ],
    );
  }

  // Desktop/Tablet slide text with dark mode support
  Widget _buildSlideTextDesktop(SlideProvider slideProvider, bool isDarkMode, double buttonHeight) {
    final Color textColor = isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600;
    final Color iconColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    final Color badgeColor = isDarkMode 
        ? (slideProvider.isPunchInMode ? Colors.blue.shade800 : Colors.red.shade800)
        : (slideProvider.isPunchInMode ? Colors.blue.shade50 : Colors.red.shade50);
    final Color badgeTextColor = slideProvider.isPunchInMode ? Colors.blue : Colors.red;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          slideProvider.isPunchInMode
              ? Icons.login_rounded
              : Icons.logout_rounded,
          color: iconColor,
          size: 20,
        ),
        
        const SizedBox(width: 12),
        
        Text(
          slideProvider.isPunchInMode
              ? "SWIPE RIGHT TO PUNCH IN"
              : "SWIPE RIGHT TO PUNCH OUT",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
        
        const SizedBox(width: 12),
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor.withOpacity(isDarkMode ? 0.3 : 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: badgeTextColor.withOpacity(isDarkMode ? 0.3 : 0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.swipe_rounded,
                color: badgeTextColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                "Swipe",
                style: TextStyle(
                  color: badgeTextColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}