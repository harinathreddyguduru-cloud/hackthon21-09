import 'package:flutter/material.dart';

class SunArcWidget extends StatelessWidget {
  final String sunrise;
  final String sunset;
  final String moonrise;
  final String moonset;

  const SunArcWidget({
    Key? key,
    required this.sunrise,
    required this.sunset,
    required this.moonrise,
    required this.moonset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.wb_sunny_outlined, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'Sunrise & sunset',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width - 64, 60),
              painter: _SunArcPainter(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sunrise', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10)),
                  Text(sunrise, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  Text('Moonrise $moonrise', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 9)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Sunset', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10)),
                  Text(sunset, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  Text('Tomorrow $moonset', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 9)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SunArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintArc = Paint()
      ..color = const Color(0xFFFFB74D)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final paintBase = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, -15, size.width, size.height);

    canvas.drawPath(path, paintArc);
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), paintBase);

    // Draw active sun position
    final sunX = size.width * 0.45;
    final sunY = size.height - (size.height * 0.7);
    final paintSun = Paint()..color = const Color(0xFFFFB74D);
    canvas.drawCircle(Offset(sunX, sunY), 6, paintSun);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
