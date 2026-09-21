import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class TempTrendChart extends StatelessWidget {
  final List<HourlyForecast> hourly;

  const TempTrendChart({Key? key, required this.hourly}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (hourly.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 90,
          child: CustomPaint(
            size: Size(MediaQuery.of(context).size.width - 40, 90),
            painter: _TrendCurvePainter(hourly: hourly),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: hourly.map((h) {
            return SizedBox(
              width: 48,
              child: Column(
                children: [
                  Text(
                    h.time,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: h.time == "Now" ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(h.icon, style: const TextStyle(fontSize: 14)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _TrendCurvePainter extends CustomPainter {
  final List<HourlyForecast> hourly;

  _TrendCurvePainter({required this.hourly});

  @override
  void paint(Canvas canvas, Size size) {
    if (hourly.length < 2) return;

    final paintLine = Paint()
      :color = const Color(0xFFFFB74D)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintFill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFFB74D).withOpacity(0.35),
          const Color(0xFFFFB74D).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final temps = hourly.map((h) => h.temp).toList();
    final minT = temps.reduce((a, b) => a < b ? a : b);
    final maxT = temps.reduce((a, b) => a > b ? a : b);
    final range = (maxT - minT) == 0 ? 1 : (maxT - minT);

    final stepX = size.width / (hourly.length - 1);
    final points = <Offset>[];

    for (int i = 0; i < hourly.length; i++) {
      final normY = (hourly[i].temp - minT) / range;
      final y = size.height - 20 - (normY * (size.height - 40));
      final x = i * stepX;
      points.add(Offset(x, y));
    }

    final path = Path();
    final fillPath = Path();

    path.moveTo(points[0].dx, points[0].dy);
    fillPath.moveTo(points[0].dx, size.height);
    fillPath.lineTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlP1 = Offset(p1.dx + stepX / 2, p1.dy);
      final controlP2 = Offset(p2.dx - stepX / 2, p2.dy);

      path.cubicTo(controlP1.dx, controlP1.dy, controlP2.dx, controlP2.dy, p2.dx, p2.dy);
      fillPath.cubicTo(controlP1.dx, controlP1.dy, controlP2.dx, controlP2.dy, p2.dx, p2.dy);
    }

    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, paintFill);
    canvas.drawPath(path, paintLine);

    // Draw active glowing badge for "Now" point
    if (points.isNotEmpty) {
      final p0 = points[0];
      final paintCircleBg = Paint()..color = const Color(0xFFE65100);
      canvas.drawCircle(p0, 10, paintCircleBg);

      final textSpan = TextSpan(
        text: '${hourly[0].temp}',
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      );
      final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(p0.dx - tp.width / 2, p0.dy - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
