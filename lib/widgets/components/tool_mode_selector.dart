import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/brush.dart';
import '../../services/drawing_controller.dart';

class ToolModeSelector extends StatelessWidget {
  const ToolModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      crossAxisAlignment: .start,
      children: [
        Text('Tools'),
        Consumer<DrawingController>(
          builder: (context, drawingCtrl, _) {
            return GridView(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 40,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              children: [
                ToolContainer(
                  onTap: () {
                    drawingCtrl.setBrush(mode: BrushMode.pen);
                  },
                  tooltip: 'Brush mode (P)',
                  icon: Icons.brush,
                  isSelected: drawingCtrl.currentBrush.mode == BrushMode.pen,
                ),
                ToolContainer(
                  onTap: () {
                    drawingCtrl.setBrush(mode: BrushMode.eraser);
                  },
                  tooltip: 'Eraser mode (E)',
                  icon: Icons.format_paint_sharp,
                  isSelected: drawingCtrl.currentBrush.mode == BrushMode.eraser,
                ),
                ToolContainer(
                  onTap: () {
                    drawingCtrl.clearCanvas();
                  },
                  tooltip: 'Clear Canvas (Ctrl + Backspace)',
                  icon: Icons.layers_clear_outlined,
                  isSelected: false,
                ),
                ToolContainer(
                  onTap: () {
                    drawingCtrl.setBrush(mode: BrushMode.eyedropper);
                  },
                  tooltip: 'Pick Color (I)',
                  icon: Icons.colorize_rounded,
                  isSelected:
                      drawingCtrl.currentBrush.mode == BrushMode.eyedropper,
                ),
                ToolContainer(
                  onTap: () {
                    drawingCtrl.undo();
                  },
                  tooltip: 'Undo (Ctrl + Z)',
                  icon: Icons.undo_rounded,
                  isSelected: false,
                ),
                ToolContainer(
                  onTap: () {
                    drawingCtrl.redo();
                  },
                  tooltip: 'Redo (Ctrl + Shift + Z)',
                  icon: Icons.redo_rounded,
                  isSelected: false,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class ToolContainer extends StatelessWidget {
  final VoidCallback onTap;
  final String tooltip;
  final IconData icon;
  final bool isSelected;

  const ToolContainer({
    super.key,
    required this.onTap,
    required this.tooltip,
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      preferBelow: false,
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? Colors.blueAccent : Colors.black,
            ),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.blueAccent : Colors.black,
          ),
        ),
      ),
    );
  }
}
