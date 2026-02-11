// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:management_app/services/auth_service.dart';
import 'package:management_app/utils/checkuser_util.dart';
import 'package:management_app/utils/systembars_utils.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  String fullText = "Pioneer Tech";
  String displayedText = "";

  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _bgOpacityAnimation;
  late Animation<Color?> _bgColorAnimation;
  late Animation<Color?> _textColorAnimation;


  late bool _isDarkMode;
  late Color _darkBgColor;
  late Color _lightBgColor;
  late Color _darkTextColor;
  late Color _lightTextColor;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystembarUtil.setSystemBar(context);
    });

    _isDarkMode = false;
    _darkBgColor = Colors.grey[900]!;
    _lightBgColor = Colors.white;
    _darkTextColor = Colors.white;
    _lightTextColor = Colors.black;

    
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    _bgOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );


    _bgColorAnimation =
        ColorTween(
          begin: Colors.transparent,
          end: _lightBgColor, 
        ).animate(
          CurvedAnimation(
            parent: _logoController,
            curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
          ),
        );

    _textColorAnimation =
        ColorTween(
          begin: Colors.transparent,
          end: _lightTextColor, 
        ).animate(
          CurvedAnimation(
            parent: _textController,
            curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
          ),
        );

    _startAnimations();
    AuthService.loadCookies();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Now it's safe to access Theme.of(context)
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;
    _darkBgColor = Colors.grey[900]!;
    _lightBgColor = Colors.white;
    _darkTextColor = Colors.white;
    _lightTextColor = Colors.black;

    
    _bgColorAnimation =
        ColorTween(
          begin: Colors.transparent,
          end: _isDarkMode ? _darkBgColor : _lightBgColor,
        ).animate(
          CurvedAnimation(
            parent: _logoController,
            curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
          ),
        );

    _textColorAnimation =
        ColorTween(
          begin: Colors.transparent,
          end: _isDarkMode ? _darkTextColor : _lightTextColor,
        ).animate(
          CurvedAnimation(
            parent: _textController,
            curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
          ),
        );
  }

  Future<void> _startAnimations() async {
    _logoController.forward().then((_) {
      _textController.forward();
      _startTypingAnimation();
    });

    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    CheckuserUtils.checkUser(context);
  }

  Future<void> _startTypingAnimation() async {
    for (int i = 0; i < fullText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (!mounted) return;
      setState(() {
        displayedText = fullText.substring(0, i + 1);
      });
    }

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    setState(() {
      displayedText = fullText;
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isSmallScreen = screenWidth < 350;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_logoController, _textController]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _isDarkMode
                    ? [Colors.grey[900]!, Colors.grey[850]!]
                    : [Colors.white, Colors.grey[50]!],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AnimatedOpacity(
                      opacity: _bgOpacityAnimation.value,
                      duration: Duration.zero,
                      child: Container(color: _bgColorAnimation.value),
                    ),
                  ),

                  Positioned.fill(
                    child: CustomPaint(
                      painter: _BackgroundPatternPainter(
                        animationValue: _logoController.value,
                        isDarkMode: _isDarkMode,
                      ),
                    ),
                  ),

                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: screenHeight * 0.15),

                        ScaleTransition(
                          scale: _logoScaleAnimation,
                          child: Container(
                            width: isSmallScreen
                                ? screenWidth * 0.25
                                : screenWidth * 0.3,
                            height: isSmallScreen
                                ? screenWidth * 0.25
                                : screenWidth * 0.3,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                    _isDarkMode ? 0.3 : 0.1,
                                  ),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 10),
                                ),
                                BoxShadow(
                                  color:
                                      (_isDarkMode
                                              ? Colors.blue[900]!
                                              : Colors.blue[100]!)
                                          .withOpacity(0.4),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                              gradient: RadialGradient(
                                colors: [
                                  _isDarkMode
                                      ? Colors.blue[800]!
                                      : Colors.blue[500]!,
                                  _isDarkMode
                                      ? Colors.blue[900]!
                                      : Colors.blue[700]!,
                                ],
                                stops: const [0.3, 1.0],
                              ),
                            ),
                            child: ClipOval(
                              child: Padding(
                                padding: EdgeInsets.all(
                                  isSmallScreen ? 12 : 16,
                                ),
                                child: Image.asset(
                                  "assets/images/app_icon.png",
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.high,
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.05),

                        
                        SizedBox(
                          height:
                              screenHeight *
                              0.07, 
                          child: AnimatedOpacity(
                            opacity: _textOpacityAnimation.value,
                            duration: Duration.zero,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                               
                              ],
                            ),
                          ),
                        ),

                        IntrinsicHeight(
                          child: AnimatedOpacity(
                            opacity: _textOpacityAnimation.value,
                            duration: Duration.zero,
                            child: Column(
                              mainAxisSize:
                                  MainAxisSize.min, // Important: use min size
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                      colors: _isDarkMode
                                          ? [
                                              Colors.blue[300]!,
                                              Colors.blue[100]!,
                                            ]
                                          : [
                                              Colors.blue[700]!,
                                              Colors.blue[900]!,
                                            ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ).createShader(bounds);
                                  },
                                  child: Text(
                                    displayedText,
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: isSmallScreen
                                          ? screenHeight * 0.028
                                          : screenHeight * 0.035,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.5,
                                      height: 1.2,
                                      color: _textColorAnimation.value,
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),

                                AnimatedOpacity(
                                  opacity: displayedText == fullText
                                      ? 1.0
                                      : 0.0,
                                  duration: const Duration(milliseconds: 500),
                                  child: Text(
                                    "Enterprise Solutions",
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: isSmallScreen
                                          ? screenHeight * 0.016
                                          : screenHeight * 0.02,
                                      fontWeight: FontWeight.w400,
                                      color: _isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(),

                        Padding(
                          padding: EdgeInsets.only(bottom: screenHeight * 0.05),
                          child: AnimatedOpacity(
                            opacity: _logoController.value > 0.7 ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: SizedBox(
                              width: screenWidth * 0.4,
                              child: LinearProgressIndicator(
                                backgroundColor: _isDarkMode
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                                color: _isDarkMode
                                    ? Colors.blue[400]
                                    : Colors.blue[600],
                                borderRadius: BorderRadius.circular(10),
                                minHeight: 4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BackgroundPatternPainter extends CustomPainter {
  final double animationValue;
  final bool isDarkMode;

  _BackgroundPatternPainter({
    required this.animationValue,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDarkMode ? Colors.blue[900]! : Colors.blue[50]!).withOpacity(
        0.05 * animationValue,
      )
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 5; i++) {
      final radius = (i + 1) * 40.0 * animationValue;
      canvas.drawCircle(
        center,
        radius,
        paint..color = paint.color.withOpacity(0.03 * (5 - i)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPatternPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue ||
        isDarkMode != oldDelegate.isDarkMode;
  }
}
