import 'package:flutter/material.dart';
import 'screens/measurement_list_screen.dart';

void main() {
  runApp(StepVisualizerApp());
}

class StepVisualizerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Step Visualizer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MeasurementListScreen(),
    );
  }
}
