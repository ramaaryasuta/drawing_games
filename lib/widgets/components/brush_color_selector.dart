import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../const/default_color.dart';
import '../../services/drawing_controller.dart';

class BrushColorSelector extends StatelessWidget {
  const BrushColorSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        spacing: 10,
        crossAxisAlignment: .start,
        children: [
          Text('Brush Color'),
          Consumer<DrawingController>(
            builder: (context, drawingCtrl, _) {
              return Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 40,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
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
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
