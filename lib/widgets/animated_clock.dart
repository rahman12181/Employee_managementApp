import 'dart:async';
import 'package:flutter/material.dart';

class LiveClockWidget extends StatefulWidget {
  final DateTime? startTime;
  final bool isRunning;

  const LiveClockWidget({
    super.key,
    required this.startTime,
    required this.isRunning,
  });

  @override
  State<LiveClockWidget> createState() => _LiveClockWidgetState();
}

class _LiveClockWidgetState extends State<LiveClockWidget> {
  late Timer _clockTimer;
  Duration _elapsedTime = Duration.zero;

  @override
  void initState() {
    super.initState();
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
  void didUpdateWidget(covariant LiveClockWidget oldWidget) {
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withAlpha(20),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: Colors.green.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDuration(_elapsedTime),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: Colors.green,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                "Time elapsed",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}