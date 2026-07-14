import 'package:flutter/material.dart';

import 'components/brush_color_selector.dart';
import 'components/tool_mode_selector.dart';
import 'components/brush_size_selector.dart';

class DrawingTool extends StatelessWidget {
  const DrawingTool({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: 150,
      height: 600,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Column(
        spacing: 10,
        crossAxisAlignment: .start,
        children: [
          ToolModeSelector(),
          BrushColorSelector(),
          BrushSizeSelector(),
        ],
      ),
    );
  }
}
