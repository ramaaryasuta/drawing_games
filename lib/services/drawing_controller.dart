import 'package:flutter/material.dart';

import '../models/brush.dart';
import '../models/stroke.dart';

class DrawingController extends ChangeNotifier {
  Brush currentBrush = Brush();

  List<Stroke> _strokes = [];
  List<Stroke> get strokes => List.unmodifiable(_strokes);
  final List<Stroke> _redoStrokes = [];

  Stroke? currentStroke;

  void setBrush({Color? color, double? width, BrushMode? mode}) {
    currentBrush = currentBrush.copyWith(
      color: color,
      width: width,
      mode: mode,
    );
    notifyListeners();
  }

  void startStroke(Offset position) {
    _redoStrokes.clear();
    currentStroke = Stroke(
      points: [position],
      color: currentBrush.mode == BrushMode.eraser
          ? Colors.grey.shade100
          : currentBrush.color,
      strokeWidth: currentBrush.width,
    );
    notifyListeners();
  }

  void appendPoint(Offset position) {
    if (currentStroke != null) {
      currentStroke!.addPoint(position);
      notifyListeners();
    }
  }

  void finishStroke() {
    if (currentStroke != null) {
      final finishedStoke = currentStroke!;
      _strokes = [..._strokes, finishedStoke];
      currentStroke = null;
      notifyListeners();
    }
  }

  void undo() {
    if (_strokes.isEmpty) return;

    final last = _strokes.removeLast();
    _redoStrokes.add(last);
    notifyListeners();
  }

  void redo() {
    if (_redoStrokes.isEmpty) return;

    final last = _redoStrokes.removeLast();
    _strokes.add(last);
    notifyListeners();
  }
}
