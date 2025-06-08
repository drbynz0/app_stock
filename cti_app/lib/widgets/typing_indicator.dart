import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    
    animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeTransition(
          opacity: Tween(begin: 0.4, end: 1.0).animate(
            CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.0, 0.33),
            ),
          ),
          child: const Text('.', style: TextStyle(fontSize: 40)),
        ),
        FadeTransition(
          opacity: Tween(begin: 0.4, end: 1.0).animate(
            CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.33, 0.66),
            ),
          ),
          child: const Text('.', style: TextStyle(fontSize: 40)),
        ),
        FadeTransition(
          opacity: Tween(begin: 0.4, end: 1.0).animate(
            CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.66, 1.0),
            ),
          ),
          child: const Text('.', style: TextStyle(fontSize: 40)),
        ),
      ],
    );
  }
}