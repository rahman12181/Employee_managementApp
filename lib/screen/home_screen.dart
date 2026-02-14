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
      vsync: this, // Now works because we're using TickerProviderStateMixin
    );
    
    _hintAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _hintController,
        curve: Curves.easeInOut,
      ),
    );
    
    _navBarController = AnimationController(
      vsync: this, // Now works because we're using TickerProviderStateMixin
      duration: const Duration(milliseconds: 800),
    );
    
    // Start animations
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: _bottomNavigationScreens,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: slideProvider.showSlideToPunch
            ? _buildSlideToContinueButton(slideProvider, isDarkMode)
            : _buildPremiumBottomNavigation(isDarkMode),
      ),
    );
  }

  Widget _buildPremiumBottomNavigation(bool isDarkMode) {
    final theme = Theme.of(context);
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    Colors.grey[850]!,
                    Colors.grey[900]!,
                  ]
                : [
                    Colors.white,
                    Colors.grey[50]!,
                  ],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: (isDarkMode ? Colors.blue : theme.colorScheme.primary).withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDarkMode 
                ? Colors.grey[700]! 
                : Colors.white.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildPremiumNavButton(
              icon: Icons.home_rounded,
              label: "Home",
              index: 0,
              isDarkMode: isDarkMode,
            ),
            _buildPremiumNavButton(
              icon: Icons.dashboard_rounded,
              label: "Dashboard",
              index: 1,
              isDarkMode: isDarkMode,
            ),
            _buildPremiumNavButton(
              icon: Icons.calendar_month_rounded,
              label: "History",
              index: 2,
              isDarkMode: isDarkMode,
            ),
            _buildPremiumNavButton(
              icon: Icons.person_rounded,
              label: "Profile",
              index: 3,
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumNavButton({
    required IconData icon,
    required String label,
    required int index,
    required bool isDarkMode,
  }) {
    final bool active = _selectedIndex == index;
    final theme = Theme.of(context);
    
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.9, end: 1),
      duration: Duration(milliseconds: active ? 300 : 200),
      curve: Curves.easeOutBack,
      builder: (context, double scale, child) {
        return Transform.scale(
          scale: active ? scale : 1.0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _onItemTapped(index),
              borderRadius: BorderRadius.circular(20),
              splashColor: (active ? theme.colorScheme.primary : Colors.grey).withOpacity(0.2),
              highlightColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: active
                    ? BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.2),
                            theme.colorScheme.primary.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      )
                    : null,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (active)
                          TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 400),
                            builder: (context, double value, child) {
                              return Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      theme.colorScheme.primary.withOpacity(0.3 * value),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        Icon(
                          icon,
                          size: active ? 30 : 24,
                          color: active
                              ? theme.colorScheme.primary
                              : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: active ? 11 : 10,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active
                            ? theme.colorScheme.primary
                            : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                        letterSpacing: 0.3,
                      ),
                      child: Text(label),
                    ),
                    if (active)
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 400),
                        builder: (context, double value, child) {
                          return Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: 20 * value,
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withOpacity(0.5),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSlideToContinueButton(SlideProvider slideProvider, bool isDarkMode) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    Colors.grey[850]!,
                    Colors.grey[900]!,
                  ]
                : [
                    Colors.white,
                    Colors.grey[50]!,
                  ],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: slideProvider.isPunchInMode 
                  ? Colors.blue.withOpacity(0.3) 
                  : Colors.red.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: slideProvider.isPunchInMode 
                ? Colors.blue.withOpacity(0.3) 
                : Colors.red.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: _buildSlideButton(slideProvider, isDarkMode),
      ),
    );
  }

  Widget _buildSlideButton(SlideProvider slideProvider, bool isDarkMode) {
    return SizedBox(
      height: 50,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const double sideButtonSize = 40;
          const double spacing = 12;

          final double sliderWidth =
              constraints.maxWidth - (sideButtonSize * 2) - (spacing * 2);

          return Row(
            children: [
              // Close button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: slideProvider.hideSlideButton,
                  borderRadius: BorderRadius.circular(sideButtonSize / 2),
                  child: Container(
                    width: sideButtonSize,
                    height: sideButtonSize,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey[700]!,
                          Colors.grey[800]!,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: spacing),

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
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDarkMode
                            ? [Colors.grey[700]!, Colors.grey[800]!]
                            : [Colors.grey[200]!, Colors.grey[300]!],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
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
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: (slideProvider.isPunchInMode ? Colors.blue : Colors.red)
                                    .withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),

                        // Sliding button
                        Positioned(
                          left: (sliderWidth - 50) * slideProvider.slideProgress,
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
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white,
                                        Colors.grey[100]!,
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                      BoxShadow(
                                        color: (slideProvider.isPunchInMode ? Colors.blue : Colors.red)
                                            .withOpacity(0.4),
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
                                        ? Colors.blue
                                        : Colors.red,
                                    size: 24,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Center text
                        Center(
                          child: Opacity(
                            opacity: 1 - slideProvider.slideProgress.clamp(0.0, 0.5),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedBuilder(
                                  animation: _hintAnimation,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(_hintAnimation.value, 0),
                                      child: Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        color: isDarkMode ? Colors.white70 : Colors.grey[600],
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
                                  color: isDarkMode ? Colors.white70 : Colors.grey[600],
                                  size: 18,
                                ),
                                
                                const SizedBox(width: 8),
                                
                                Text(
                                  slideProvider.isPunchInMode
                                      ? "Slide to Punch In"
                                      : "Slide to Punch Out",
                                  style: TextStyle(
                                    color: isDarkMode ? Colors.white70 : Colors.grey[600],
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
                                        color: isDarkMode ? Colors.white70 : Colors.grey[600],
                                        size: 14,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: spacing),

              // Check button
              AnimatedOpacity(
                opacity: slideProvider.slideProgress > 0.7 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: sideButtonSize,
                    height: sideButtonSize,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: slideProvider.isPunchInMode
                            ? [Colors.blue.shade400, Colors.blue.shade600]
                            : [Colors.red.shade400, Colors.red.shade600],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (slideProvider.isPunchInMode ? Colors.blue : Colors.red)
                              .withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}