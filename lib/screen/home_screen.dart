import 'package:flutter/material.dart';
import 'package:management_app/screen/HomeMain_Screen.dart';
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
  double _slideValue = 0.0;
  bool _isSliding = false;

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
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth - 40; // Minus margins
    final maxSlide = containerWidth - 130; // Adjusted for button width and padding

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
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 14),
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
              ? _buildSlideToContinueButton(slideProvider, maxSlide)
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

  Widget _buildSlideToContinueButton(SlideProvider slideProvider, double maxSlide) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white70),
              onPressed: () {
                slideProvider.hideSlideButton();
                setState(() {
                  _slideValue = 0.0;
                  _isSliding = false;
                });
              },
            ),
            Text(
              slideProvider.isPunchInMode ? "Slide to Punch In" : "Slide to Punch Out",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 40), // For balance
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[700],
            borderRadius: BorderRadius.circular(25),
          ),
          child: Stack(
            children: [
              // Background track
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.grey[700],
                  ),
                ),
              ),
              
              // Instruction text
              if (!_isSliding)
                const Positioned.fill(
                  child: Center(
                    child: Text(
                      "Slide to continue →",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              
              // Sliding button
              AnimatedPositioned(
                duration: const Duration(milliseconds: 100),
                left: _slideValue,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    final newValue = (_slideValue + details.delta.dx)
                        .clamp(0.0, maxSlide);
                    
                    setState(() {
                      _slideValue = newValue;
                      _isSliding = newValue > 0;
                    });
                  },
                  onPanEnd: (details) {
                    if (_slideValue > maxSlide - 30) {
                      // Slide completed
                      slideProvider.completePunch();
                      setState(() {
                        _slideValue = 0.0;
                        _isSliding = false;
                      });
                    } else {
                      // Reset if not completed
                      setState(() {
                        _slideValue = 0.0;
                        _isSliding = false;
                      });
                    }
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _isSliding 
                          ? (slideProvider.isPunchInMode ? Colors.blue : Colors.red)
                          : Colors.white,
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
                      slideProvider.isPunchInMode ? Icons.login : Icons.logout,
                      color: _isSliding ? Colors.white : Colors.grey,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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