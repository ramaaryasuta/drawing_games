import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../services/drawing_controller.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/drawing_tool.dart';

class CanvasPage extends StatefulWidget {
  const CanvasPage({super.key});

  @override
  State<CanvasPage> createState() => _CanvasPageState();
}

class _CanvasPageState extends State<CanvasPage> {
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _keyboardFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      onKeyEvent: (event) {
        final drawingController = context.read<DrawingController>();
        if (event is KeyDownEvent) {
          final isCtrlPressed = HardwareKeyboard.instance.isControlPressed;
          final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;

          if (isCtrlPressed &&
              isShiftPressed &&
              event.logicalKey == LogicalKeyboardKey.keyZ) {
            drawingController.redo();
          } else if (isCtrlPressed &&
              event.logicalKey == LogicalKeyboardKey.keyZ) {
            drawingController.undo();
          }
        }
      },
      child: const Scaffold(
        backgroundColor: Colors.deepPurpleAccent,
        body: Column(
          mainAxisAlignment: .center,
          children: [
            Row(
              spacing: 20,
              mainAxisAlignment: .center,
              crossAxisAlignment: .start,
              children: [DrawingTool(), DrawingCanvas()],
            ),
          ],
        ),
      ),
    );
  }
}
