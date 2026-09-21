import 'package:flutter/material.dart';

class LifestyleGrid extends StatelessWidget {
  final List<Map<String, dynamic>> activities;

  const LifestyleGrid({Key? key, required this.activities}) : super(key: key);

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'biking': return Icons.directions_bike;
      case 'satellite': return Icons.wb_twilight;
      case 'fishing': return Icons.phishing;
      case 'sailing': return Icons.directions_boat;
      case 'pill': return Icons.medication;
      case 'bug': return Icons.bug_report;
      default: return Icons.fitness_center;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final act = activities[index];
        final name = act['name'] ?? '';
        final status = act['status'] ?? '';
        final iconStr = act['icon'] ?? '';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_getIcon(iconStr), color: Colors.white, size: 20),
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextSpanOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                status,
                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 10),
              ),
            ],
          ),
        );
      },
    );
  }
}
