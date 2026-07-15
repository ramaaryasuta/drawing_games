import 'package:flutter/material.dart';

import '../models/brush.dart';
import '../models/history_action.dart';
import '../models/stroke.dart';

class DrawingController extends ChangeNotifier {
  Brush currentBrush = Brush(width: 10);
  bool showCursor = true;

  List<Stroke> _strokes = [];
  List<Stroke> get strokes => List.unmodifiable(_strokes);

  final List<HistoryAction> _undoStack = [];
  final List<HistoryAction> _redoStack = [];

  Stroke? currentStroke;

  void setShowCursor(bool v) {
    showCursor = v;
    notifyListeners();
  }

  void setBrush({Color? color, double? width, BrushMode? mode}) {
    currentBrush = currentBrush.copyWith(
      color: color,
      width: width,
      mode: mode,
    );
    notifyListeners();
  }

  void startStroke(Offset position) {
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
    if (currentStroke == null) return;
    currentStroke!.addPoint(position);
    notifyListeners();
  }

  void finishStroke() {
    if (currentStroke == null) return;
    final finishedStroke = currentStroke!;
    _strokes = [..._strokes, finishedStroke];

    _undoStack.add(HistoryAction(ActionType.draw, [finishedStroke]));
    _redoStack.clear();

    currentStroke = null;
    notifyListeners();
  }

  void clearCanvas() {
    if (_strokes.isEmpty) return;

    _undoStack.add(HistoryAction(ActionType.clear, List.of(_strokes)));
    _redoStack.clear();

    _strokes = [];
    notifyListeners();
  }

  Color? pickColor(Offset position) {
    const tolerance = 10.0;

    for (int i = _strokes.length - 1; i >= 0; i--) {
      final stroke = _strokes[i];

      for (final point in stroke.points) {
        final distance = (point - position).distance;

        if (distance <= tolerance) {
          return stroke.color;
        }
      }
    }

    return null;
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    final action = _undoStack.removeLast();

    switch (action.type) {
      case ActionType.draw:
        _strokes.removeLast();
        break;
      case ActionType.clear:
        _strokes = [..._strokes, ...action.strokes];
        break;
    }

    _redoStack.add(action);
    notifyListeners();
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    final action = _redoStack.removeLast();

    switch (action.type) {
      case ActionType.draw:
        _strokes = [..._strokes, ...action.strokes];
        break;
      case ActionType.clear:
        _strokes = [];
        break;
    }

    _undoStack.add(action);
    notifyListeners();
  }
}
