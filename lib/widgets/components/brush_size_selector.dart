import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../services/drawing_controller.dart';
import '../../utils/utils.dart';

class BrushSizeSelector extends StatefulWidget {
  const BrushSizeSelector({super.key});

  @override
  State<BrushSizeSelector> createState() => _BrushSizeSelectorState();
}

class _BrushSizeSelectorState extends State<BrushSizeSelector> {
  late DrawingController _drawingController;

  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _drawingController = context.read<DrawingController>();
    _textController = TextEditingController(
      text: _drawingController.currentBrush.width.toInt().toString(),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _updateFromText(String value) {
    if (value.isEmpty) return;

    double? newValue = double.tryParse(value);
    if (newValue != null) {
      if (newValue < 1) newValue = 1;
      if (newValue > 40) newValue = 40;

      _drawingController.setBrush(width: newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingController>(
      builder: (context, drawingCtrl, _) {
        return Column(
          spacing: 8,
          crossAxisAlignment: .start,
          children: [
            Text(
              '${uppercaseFirstLetter(drawingCtrl.currentBrush.mode.name.toString())} Size',
            ),
            Row(
              spacing: 20,
              children: [
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      padding: const EdgeInsets.all(0),
                      trackShape: const RoundedRectSliderTrackShape(),
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                        disabledThumbRadius: 6,
                      ),
                    ),
                    child: Slider(
                      value: drawingCtrl.currentBrush.width,
                      min: 1.0,
                      max: 40.0,
                      divisions: 10,
                      label: drawingCtrl.currentBrush.width.round().toString(),
                      onChanged: (double value) {
                        setState(() {
                          _drawingController.setBrush(width: value);
                          _textController.text = value.toInt().toString();
                        });
                      },
                    ),
                  ),
                ),

                SizedBox(
                  width: 40,
                  child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 2,
                      ),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: _updateFromText,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 1),

            Row(
              children: [
                Expanded(child: Text('Show Cursor')),
                SizedBox(
                  width: 40,
                  height: 24,
                  child: Transform.scale(
                    scale: 0.7,
                    child: Switch(
                      value: drawingCtrl.showCursor,
                      onChanged: (v) => drawingCtrl.setShowCursor(v),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
