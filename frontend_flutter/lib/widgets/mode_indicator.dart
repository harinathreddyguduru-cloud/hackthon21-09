import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ModeIndicator extends StatelessWidget {
  final bool isDemo;
  final String label;
  final String subtitle;

  const ModeIndicator({
    Key? key,
    required this.isDemo,
    required this.label,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = isDemo ? const Color(0xFFFFF3E0) : AppColors.lightSkyBlue;
    final borderColor = isDemo ? AppColors.warning : AppColors.primarySkyBlue;
    final textColor = isDemo ? const Color(0xFFE65100) : const Color(0xFF0277BD);
    final dotColor = isDemo ? const Color(0xFFFF9800) : const Color(0xFF4CAF50);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withOpacity(0.5), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: dotColor.withOpacity(0.6),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.isNotEmpty ? label : (isDemo ? '🟠 DEMO MODE' : '🟢 LIVE WEATHER'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  subtitle.isNotEmpty ? subtitle : (isDemo ? 'Simulated weather data' : 'Weather data from Open-Meteo'),
                  style: TextStyle(
                    fontSize: 11,
                    color: textColor.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isDemo ? 'SIMULATION' : 'REAL FACT',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
