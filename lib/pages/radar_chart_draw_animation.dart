import 'dart:math';

import 'package:drawing_animation/drawing_animation.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class RadarChartAnimation extends StatefulWidget {
  const RadarChartAnimation({super.key});

  @override
  State<RadarChartAnimation> createState() => _RadarChartAnimationState();
}

class _RadarChartAnimationState extends State<RadarChartAnimation>
    with SingleTickerProviderStateMixin {
  int headsNum = 6;
  int statsNum = 3;
  List<int> statsRadiusNum = [10, 40, 70, 90, 100];

  List<int> headsData = [66, 40, 90, 18, 80, 100];

  ///heads data length must be equal to headsNum

  late final controller =
      AnimationController(vsync: this, duration: const Duration(seconds: 3));

  @override
  void initState() {
    //forward animation and repeat
    controller.forward();
    //controller.repeat(reverse: false);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Radar Chart Animation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                    alignment: Alignment.center,
                    children: statsRadiusNum
                        .map<Widget>((radius) => CustomPaint(
                              painter: RadarChartPainter(
                                  radius.toDouble(), headsNum),
                            ))
                        .toList()
                      ..add(
                        AnimatedBuilder(
                            animation: controller,
                            builder: (context, _) {
                              return SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: CustomPaint(
                                    painter: RadarChartStatsPainter(
                                        headsData, headsNum, controller.value),
                                  ));
                            }),
                      )
                    //..add(animatedStats())
                    )),
          ],
        ),
      ),
    );
  }
}

class RadarChartStatsPainter extends CustomPainter {
  final List<int> stats;
  final int sides;

  final double percent;

  RadarChartStatsPainter(this.stats, this.sides, this.percent);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(size.width, size.height),
        [
          Colors.lime,
          Colors.red,
        ],
      )
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(getPath(size, paint, percent), paint);
  }

  Path getPath(Size size, Paint paint, double percent) {
    final center = Offset(size.width / 2, size.height / 2);

    final path = Path();
    double eachStatsPercent = 1 / (sides + 1);
    Offset? lastOffset;
    for (var i = 0; i <= sides; i++) {
      final bool isLast = i == sides;
      final index = isLast ? 0 : i;
      final points = _getPolygonPoints(center, stats[index].toDouble(), sides);
      final currentPercent =
          min(eachStatsPercent, max(0, percent - (eachStatsPercent * i)));
      final actualPercent = currentPercent / eachStatsPercent;
      final offset = points[index];
      if (i == 0) {
        path.moveTo(offset.dx, offset.dy);
      } else {
        // if (actualPercent == 1.0) {
        //   path.lineTo(points[i].dx, points[i].dy);
        // } else {
        if (actualPercent > 0.0 && actualPercent < 1.0) {
          final middleOffset =
              getMiddleOffset(lastOffset!, offset, actualPercent);
          path.lineTo(middleOffset.dx, middleOffset.dy);
        } else if (actualPercent == 1.0) {
          path.quadraticBezierTo(
              lastOffset!.dx, lastOffset!.dy, offset.dx, offset.dy);
        }
        //}
      }
      lastOffset = offset;
    }
    if (percent == 1.0) {
      path.close();
    }
    return path;
  }

  Offset getMiddleOffset(Offset offset1, Offset offset2, double percent) {
    assert(percent >= 0.0 && percent <= 1.0,
        'Percent must be between 0.0 and 1.0');

    double dx = offset1.dx + ((offset2.dx - offset1.dx) * percent);
    double dy = offset1.dy + ((offset2.dy - offset1.dy) * percent);

    return Offset(dx, dy);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class RadarChartPainter extends CustomPainter {
  final double radius;

  final int sideNum;

  RadarChartPainter(this.radius, this.sideNum);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final hexagonPoints = _getPolygonPoints(center, radius, sideNum);

    final path = Path()..addPolygon(hexagonPoints, true);

    // Draw filled polygon
    canvas.drawPath(path, paint);

    // Draw outline
    paint
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);

    // Draw axes
    paint
      ..color = Colors.blue.shade100
      ..strokeWidth = 1.0;
    for (var point in hexagonPoints) {
      canvas.drawLine(center, point, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

List<Offset> _getPolygonPoints(Offset center, double radius, int sides) {
  final angle = (360 / sides) * pi / 180.0;
  const radian90 = 90 * pi / 180.0;
  return List.generate(sides, (index) {
    final x = center.dx + radius * cos(angle * index - radian90);
    final y = center.dy + radius * sin(angle * index - radian90);
    return Offset(x, y);
  });
}
