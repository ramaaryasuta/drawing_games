import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/stroke.dart';
import '../services/drawing_controller.dart';

class DrawingCanvas extends StatelessWidget {
  const DrawingCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingController>(
      builder: (context, drawingCtrl, _) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Listener(
            onPointerDown: (e) {
              drawingCtrl.startStroke(e.localPosition);
            },
            onPointerMove: (e) {
              drawingCtrl.appendPoint(e.localPosition);
            },
            onPointerUp: (e) {
              drawingCtrl.finishStroke();
            },
            child: ClipRect(
              child: CustomPaint(
                painter: MasterPainter(
                  strokes: drawingCtrl.strokes,
                  currentStroke: drawingCtrl.currentStroke,
                ),
                size: const Size(700, 450),
              ),
            ),
          ),
        );
      },
    );
  }
}

class MasterPainter extends CustomPainter {
  List<Stroke> strokes;
  Stroke? currentStroke; // live draw

  MasterPainter({required this.strokes, required this.currentStroke});

  void drawStroke(Canvas canvas, Stroke stroke) {
    if (stroke.points.isEmpty) return;

    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (stroke.points.length == 1) {
      final dotPaint = Paint()
        ..color = paint.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(stroke.points.first, paint.strokeWidth / 2, dotPaint);
      return;
    }

    final path = Path();
    final firstPoint = stroke.points.first;

    path.moveTo(firstPoint.dx, firstPoint.dy); // start here for index 0
    /// start from index 1 cause moveTo() has been set on index 0
    for (int i = 1; i < stroke.points.length - 1; i++) {
      final p0 = stroke.points[i];
      final p1 = stroke.points[i + 1];
      final midPoint = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      path.quadraticBezierTo(p0.dx, p0.dy, midPoint.dx, midPoint.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var stroke in strokes) {
      drawStroke(canvas, stroke);
    }
    if (currentStroke != null) {
      drawStroke(canvas, currentStroke!);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
