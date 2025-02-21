import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:step_visualizer/main.dart';

void main() {
  testWidgets('App loads and home screen appears', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(StepVisualizerApp());

    // Check if the main home screen title exists.
    expect(find.text('Step Visualizer'), findsOneWidget);
  });
}
