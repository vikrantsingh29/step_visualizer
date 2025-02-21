import 'package:flutter/material.dart';
import '../models/measurement.dart';
import 'calculated_steps_screen.dart';
import 'raw_sensor_data_screen.dart';
import 'calculated_steps_multi_visualization_screen.dart';

class MeasurementDetailScreen extends StatelessWidget {
  final Measurement measurement;

  MeasurementDetailScreen({required this.measurement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Measurement: ${measurement.id}'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Start: ${measurement.startTime}'),
            Text('End: ${measurement.endTime}'),
            SizedBox(height: 20),
            ElevatedButton(
  child: Text("View Calculated Steps"),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CalculatedStepsMultiVisualizationScreen(
            measurementId: measurement.id),
      ),
    );
  },
),
            SizedBox(height: 10),
            ElevatedButton(
              child: Text('View Raw Sensor Data'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RawSensorDataScreen(measurementId: measurement.id),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
