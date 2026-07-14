import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'page/canvas_page.dart';
import 'services/drawing_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => DrawingController())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Drawing game',
      debugShowCheckedModeBanner: false,
      home: CanvasPage(),
    );
  }
}
