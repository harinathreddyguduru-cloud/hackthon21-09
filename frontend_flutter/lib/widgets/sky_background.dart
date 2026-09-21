import 'package:flutter/material.dart';
import 'dart:math' as math;

class SkyBackground extends StatefulWidget {
  final String conditionCode;
  final Widget child;

  const SkyBackground({
    Key? key,
    required this.conditionCode,
    required this.child,
  }) : super(key: key);

  @override
  State<SkyBackground> createState() => _SkyBackgroundState();
}

class _SkyBackgroundState extends State<SkyBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> _getSkyGradients() {
    final code = widget.conditionCode.toLowerCase();
    if (code.contains('rain')) {
      return [
        const Color(0xFF2B4C6F),
        const Color(0xFF3B6898),
        const Color(0xFF5A8DBE),
      ];
    }
    if (code.contains('clear') || code.contains('sun')) {
      return [
        const Color(0xFF2C74C3),
        const Color(0xFF4FA0EE),
        const Color(0xFF80C3FF),
      ];
    }
    // Default sky blue matching reference image
    return [
      const Color(0xFF327FD2),
      const Color(0xFF519BE7),
      const Color(0xFF7CB8F8),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getSkyGradients();

    return Stack(
      children: [
        // 1. Base Gradient Sky
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors,
            ),
          ),
        ),

        // 2. 3D Sun Flare Light Ray Effect
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final val = _controller.value * 2 * math.pi;
            return Positioned(
              top: -60,
              left: MediaQuery.of(context).size.width / 2 - 120,
              child: Opacity(
                opacity: 0.6 + 0.2 * math.sin(val),
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.8),
                        Colors.yellow.withOpacity(0.4),
                        Colors.white.withOpacity(0.0),
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // 3. Main Child Content (Overlaid translucent glass design)
        widget.child,
      ],
    );
  }
}
