import 'stroke.dart';

enum ActionType { draw, clear }

class HistoryAction {
  final ActionType type;
  final List<Stroke> strokes;
  HistoryAction(this.type, this.strokes);
}
