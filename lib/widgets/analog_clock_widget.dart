import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class AnalogClockWidget extends StatefulWidget {
  final DateTime? startTime;
  final bool isRunning;
  final double size;

  const AnalogClockWidget({
    super.key,
    required this.startTime,
    required this.isRunning,
    this.size = 200,
  });

  @override
  State<AnalogClockWidget> createState() => _AnalogClockWidgetState();
}

class _AnalogClockWidgetState extends State<AnalogClockWidget> 
    with SingleTickerProviderStateMixin {
  late Timer _clockTimer;
  Duration _elapsedTime = Duration.zero;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    
    // Animation for smooth second hand movement
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    

    if (widget.isRunning && widget.startTime != null) {
      _startClock();
    }
  }

  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && widget.startTime != null) {
        setState(() {
          _elapsedTime = DateTime.now().difference(widget.startTime!);
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant AnalogClockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isRunning && !oldWidget.isRunning && widget.startTime != null) {
      _startClock();
    } else if (!widget.isRunning && oldWidget.isRunning) {
      _clockTimer.cancel();
    }
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.startTime == null) return const SizedBox.shrink();

    final totalSeconds = _elapsedTime.inSeconds;
    final secondsAngle = (totalSeconds % 60) * 6 * (3.14159 / 180); // 6 degrees per second
    final minutesAngle = (_elapsedTime.inMinutes % 60) * 6 * (3.14159 / 180); // 6 degrees per minute
    final hoursAngle = (_elapsedTime.inHours % 12) * 30 * (3.14159 / 180); // 30 degrees per hour

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Analog Clock
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: Colors.grey.shade300,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Clock center dot
              Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                ),
              ),
              
              // Hour hand
              Transform.rotate(
                angle: hoursAngle,
                child: Center(
                  child: Container(
                    width: 4,
                    height: widget.size * 0.25,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              
              // Minute hand
              Transform.rotate(
                angle: minutesAngle,
                child: Center(
                  child: Container(
                    width: 3,
                    height: widget.size * 0.35,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ),
              ),
              
              // Second hand with animation
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: secondsAngle,
                    child: Center(
                      child: Container(
                        width: 2,
                        height: widget.size * 0.4,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              // Clock numbers/marks
              ...List.generate(12, (index) {
                final angle = index * 30 * (3.14159 / 180);
                final number = index == 0 ? 12 : index;
                final isHourMark = index % 3 == 0;
                
                return Positioned(
                  left: widget.size / 2 + (widget.size * 0.4) * -sin(angle) - (isHourMark ? 10 : 5),
                  top: widget.size / 2 + (widget.size * 0.4) * cos(angle) - (isHourMark ? 10 : 5),
                  child: Container(
                    width: isHourMark ? 20 : 10,
                    height: isHourMark ? 20 : 10,
                    alignment: Alignment.center,
                    child: isHourMark
                        ? Text(
                            '$number',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                            ),
                          ),
                  ),
                );
              }),
            ],
          ),
        ),
        
        const SizedBox(height: 10),
        
        // Digital time below clock
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.shade200, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer,
                color: Colors.green.shade700,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                _formatDuration(_elapsedTime),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 5),
        
        Text(
          "Working Hours",
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}