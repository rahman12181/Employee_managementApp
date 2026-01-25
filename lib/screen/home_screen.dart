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

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _bottomNavigationScreens = [
    const HomemainScreen(),
    const DashboardScreen(),
    const AttendanceScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final slideProvider = Provider.of<SlideProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      body: Container(
        color: theme.scaffoldBackgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: _bottomNavigationScreens[_selectedIndex],
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: slideProvider.showSlideToPunch
                ? Colors.grey[800]
                : theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(40),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: slideProvider.showSlideToPunch
              ? _buildSlideToContinueButton(slideProvider)
              : _buildNormalNavigation(),
        ),
      ),
    );
  }

  Widget _buildNormalNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        navButton(Icons.home, "Home", 0),
        navButton(Icons.dashboard_customize, "Dashboard", 1),
        navButton(Icons.calendar_today, "History", 2),
        navButton(Icons.account_box, "Profile", 3),
      ],
    );
  }

  Widget _buildSlideToContinueButton(SlideProvider slideProvider) {
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
              /// ❌ Close Button
              GestureDetector(
                onTap: slideProvider.hideSlideButton,
                child: Container(
                  width: sideButtonSize,
                  height: sideButtonSize,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
              ),

              const SizedBox(width: spacing),

           
              SizedBox(
                width: sliderWidth,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    final delta = details.delta.dx;
                    final newProgress =
                        (slideProvider.slideProgress + delta / sliderWidth)
                            .clamp(0.0, 1.0);

                    slideProvider.updateSlideProgress(newProgress);

                    if (newProgress >= 0.95) {
                      Future.delayed(const Duration(milliseconds: 100), () {
                        slideProvider.completePunch();
                      });
                    }
                  },
                  onHorizontalDragEnd: (_) {
                    if (slideProvider.slideProgress < 0.95) {
                      slideProvider.updateSlideProgress(0.0);
                    }
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        /// Progress background
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          width: sliderWidth * slideProvider.slideProgress,
                          decoration: BoxDecoration(
                            color: slideProvider.isPunchInMode
                                ? Colors.blue
                                : Colors.red,
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),

                        /// Thumb
                        Positioned(
                          left:
                              (sliderWidth - 50) * slideProvider.slideProgress,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              slideProvider.isPunchInMode
                                  ? Icons.login
                                  : Icons.logout,
                              color: slideProvider.isPunchInMode
                                  ? Colors.blue
                                  : Colors.red,
                            ),
                          ),
                        ),

                        /// Center Text
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                slideProvider.isPunchInMode
                                    ? Icons.login
                                    : Icons.logout,
                                color: Colors.white70,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                slideProvider.isPunchInMode
                                    ? "Slide to Punch In"
                                    : "Slide to Punch Out",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
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

              const SizedBox(width: spacing),

              /// ✔ Check Icon
              AnimatedOpacity(
                opacity: slideProvider.slideProgress > 0.7 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: sideButtonSize,
                  height: sideButtonSize,
                  decoration: BoxDecoration(
                    color: slideProvider.isPunchInMode
                        ? Colors.blue
                        : Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget navButton(IconData icon, String label, int index) {
    final bool active = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: active ? 27 : 22,
            color: active ? Colors.white : Colors.white70,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: active ? 11 : 10,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              color: active ? Colors.white : Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
