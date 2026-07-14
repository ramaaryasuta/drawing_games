import 'dart:ui';

class Stroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  Stroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });

  void addPoint(Offset point) {
    points.add(point);
  }
}
