import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../theme/app_theme.dart';

class AlertBanner extends StatelessWidget {
  final AlertItem alert;

  const AlertBanner({Key? key, required this.alert}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (alert.type == 'normal') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.lightSkyBlue,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primarySkyBlue.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: AppColors.success, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    alert.message,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Color bannerBg;
    Color borderColor;
    Color textColor;

    if (alert.type == 'rain') {
      bannerBg = AppColors.rainBlue.withOpacity(0.12);
      borderColor = AppColors.rainBlue;
      textColor = const Color(0xFF1976D2);
    } else if (alert.type == 'heat') {
      bannerBg = AppColors.warning.withOpacity(0.15);
      borderColor = AppColors.warning;
      textColor = const Color(0xFFE65100);
    } else if (alert.type == 'wind') {
      bannerBg = AppColors.primarySkyBlue.withOpacity(0.12);
      borderColor = AppColors.primarySkyBlue;
      textColor = const Color(0xFF0277BD);
    } else {
      bannerBg = AppColors.danger.withOpacity(0.12);
      borderColor = AppColors.danger;
      textColor = const Color(0xFFC62828);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withOpacity(0.6), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                alert.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: borderColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  alert.severity.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            alert.message,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textDark,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.shield_outlined, size: 14, color: textColor),
              const SizedBox(width: 4),
              Text(
                'Recommended: ${alert.action}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
