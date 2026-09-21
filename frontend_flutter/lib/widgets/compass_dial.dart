import 'package:flutter/material.dart';
import 'dart:math' as math;

class CompassDial extends StatelessWidget {
  final int degrees;
  final String cardinal;
  final int speed;

  const CompassDial({
    Key? key,
    required this.degrees,
    required this.cardinal,
    required this.speed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Compass ring background
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.12),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
            ),
          ),

          // N, E, S, WLabels
          Positioned(top: 12, child: Text('N', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 10, fontWeight: FontWeight.bold))),
          Positioned(bottom: 12, child: Text('S', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 10, fontWeight: FontWeight.bold))),
          Positioned(left: 12, child: Text('W', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 10, fontWeight: FontWeight.bold))),
          Positioned(right: 12, child: Text('E', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 10, fontWeight: FontWeight.bold))),

          // Rotating needle pointer
          Transform.rotate(
            angle: (degrees * math.pi) / 180,
            child: Container(
              width: 4,
              height: 70,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF4DA8FF), Colors.transparent],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Center Label (e.g. SSW Force 3)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  cardinal,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                ),
                Text(
                  '$speed km/h',
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
