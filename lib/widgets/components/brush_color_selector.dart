import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

import '../../const/default_color.dart';
import '../../models/brush.dart';
import '../../services/drawing_controller.dart';

class BrushColorSelector extends StatelessWidget {
  const BrushColorSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      crossAxisAlignment: .start,
      children: [
        Text('Brush Color'),
        Consumer<DrawingController>(
          builder: (context, drawingCtrl, _) {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 40,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              shrinkWrap: true,
              itemCount: MConstant.defaultColors.length,
              itemBuilder: (context, index) {
                final color = MConstant.defaultColors[index];
                return InkWell(
                  onTap: () {
                    drawingCtrl.setBrush(color: color);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(color: Colors.black, width: .5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: drawingCtrl.currentBrush.color == color
                        ? const Icon(Icons.check_box_outlined)
                        : null,
                  ),
                );
              },
            );
          },
        ),
        Text('Custom Color'),
        const CustomColorRow(),
      ],
    );
  }
}

class CustomColorRow extends StatefulWidget {
  const CustomColorRow({super.key});

  @override
  State<CustomColorRow> createState() => _CustomColorRowState();
}

class _CustomColorRowState extends State<CustomColorRow> {
  late TextEditingController _hexController;
  Color? _lastKnownColor;

  @override
  void initState() {
    super.initState();
    _hexController = TextEditingController();
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  String _colorToHex(Color color) {
    return color
        .toARGB32()
        .toRadixString(16)
        .padLeft(8, '0')
        .substring(2)
        .toUpperCase();
  }

  Color? _hexToColor(String hex) {
    var value = hex.replaceAll('#', '').trim();
    if (value.length == 6) value = 'FF$value';
    if (value.length != 8) return null;

    final parsed = int.tryParse(value, radix: 16);
    if (parsed == null) return null;

    return Color(parsed);
  }

  void _syncHexFromColor(Color color) {
    if (_lastKnownColor != color) {
      _lastKnownColor = color;
      _hexController.text = _colorToHex(color);
    }
  }

  void _submitHex(DrawingController drawingCtrl, String value) {
    final color = _hexToColor(value);
    if (color != null) {
      drawingCtrl.setBrush(color: color);
    } else {
      // input tidak valid → kembalikan text ke warna aktif sebelumnya
      _hexController.text = _colorToHex(drawingCtrl.currentBrush.color);
    }
  }

  void _openColorWheel(BuildContext context, DrawingController drawingCtrl) {
    Color pickedColor = drawingCtrl.currentBrush.color;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: drawingCtrl.currentBrush.color,
              onColorChanged: (color) {
                pickedColor = color;
                drawingCtrl.setBrush(mode: BrushMode.pen);
              },
              enableAlpha: false,
              displayThumbColor: true,
              labelTypes: const [ColorLabelType.hex, ColorLabelType.rgb],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                drawingCtrl.setBrush(color: pickedColor);
                Navigator.of(context).pop();
              },
              child: const Text('Select'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawingController>(
      builder: (context, drawingCtrl, _) {
        final currentColor = drawingCtrl.currentBrush.color;
        _syncHexFromColor(currentColor);

        return Column(
          spacing: 10,
          children: [
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _openColorWheel(context, drawingCtrl),
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: currentColor,
                        border: Border.all(color: Colors.black, width: .5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                IconButton(
                  onPressed: () => _openColorWheel(context, drawingCtrl),
                  icon: const Icon(Icons.color_lens_outlined),
                  tooltip: 'Custom color',
                ),
              ],
            ),

            TextField(
              controller: _hexController,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F#]')),
                LengthLimitingTextInputFormatter(7),
              ],
              decoration: const InputDecoration(
                prefixText: '#',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) => _submitHex(drawingCtrl, value),
              onTapOutside: (_) => _submitHex(drawingCtrl, _hexController.text),
            ),
          ],
        );
      },
    );
  }
}
