import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/brush.dart';
import '../models/stroke.dart';
import '../services/drawing_controller.dart';

class DrawingCanvas extends StatefulWidget {
  const DrawingCanvas({super.key});

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  final ValueNotifier<Offset?> _cursorPosition = ValueNotifier(null);

  @override
  void dispose() {
    _cursorPosition.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // context.read: ambil sekali untuk dipakai di callback, TIDAK subscribe/rebuild
    final drawingCtrl = context.read<DrawingController>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: MouseRegion(
        onExit: (_) => _cursorPosition.value = null,
        child: Listener(
          onPointerDown: (e) {
            final brush = drawingCtrl.currentBrush;
            if (brush.mode == BrushMode.eyedropper) {
              final color = drawingCtrl.pickColor(e.localPosition);
              if (color != null) {
                drawingCtrl.setBrush(color: color, mode: BrushMode.pen);
              }
              return;
            }
            drawingCtrl.startStroke(e.localPosition);
          },
          onPointerMove: (e) {
            _cursorPosition.value = e.localPosition;
            drawingCtrl.appendPoint(e.localPosition);
          },
          onPointerHover: (e) => _cursorPosition.value = e.localPosition,
          onPointerUp: (e) => drawingCtrl.finishStroke(),
          child: ClipRect(
            child: Stack(
              children: [
                Selector<
                  DrawingController,
                  ({List<Stroke> strokes, Stroke? current})
                >(
                  selector: (_, ctrl) =>
                      (strokes: ctrl.strokes, current: ctrl.currentStroke),
                  builder: (context, data, _) {
                    return CustomPaint(
                      painter: MasterPainter(
                        strokes: data.strokes,
                        currentStroke: data.current,
                      ),
                      size: const Size(800, 500),
                    );
                  },
                ),

                Selector<
                  DrawingController,
                  ({double width, BrushMode mode, bool showCursor})
                >(
                  selector: (_, ctrl) => (
                    width: ctrl.currentBrush.width,
                    mode: ctrl.currentBrush.mode,
                    showCursor: ctrl.showCursor,
                  ),
                  builder: (context, brushData, _) {
                    if (brushData.mode == BrushMode.eyedropper ||
                        !brushData.showCursor) {
                      return const SizedBox.shrink();
                    }

                    return ValueListenableBuilder<Offset?>(
                      valueListenable: _cursorPosition,
                      builder: (context, position, _) {
                        if (position == null) return const SizedBox.shrink();

                        return CustomPaint(
                          painter: BrushCursorPainter(
                            position: position,
                            radius: brushData.width / 2,
                          ),
                          size: const Size(800, 500),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BrushCursorPainter extends CustomPainter {
  final Offset position;
  final double radius;

  BrushCursorPainter({required this.position, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final borderPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(position, radius + 1, outlinePaint);
    canvas.drawCircle(position, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant BrushCursorPainter oldDelegate) {
    return oldDelegate.position != position || oldDelegate.radius != radius;
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
