import 'package:flutter/material.dart';

enum BrushMode { pen, eraser }

class Brush {
  final Color color;
  final double width;
  BrushMode mode;

  Brush({this.color = Colors.black, this.width = 1, this.mode = BrushMode.pen});

  Brush copyWith({Color? color, double? width, BrushMode? mode}) {
    return Brush(
      color: color ?? this.color,
      width: width ?? this.width,
      mode: mode ?? this.mode,
    );
  }
}
