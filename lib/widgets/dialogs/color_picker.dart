import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

import '../../services/drawing_controller.dart';

void showColorPicker(BuildContext context) {
  final controller = context.read<DrawingController>();

  Color selectedColor = controller.currentBrush.color;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Select Color"),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selectedColor,
            onColorChanged: (color) {
              selectedColor = color;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              controller.setBrush(color: selectedColor);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}
