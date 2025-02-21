import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/measurement.dart';

class CalculatedStepsMultiVisualizationScreen extends StatefulWidget {
  final String measurementId;

  CalculatedStepsMultiVisualizationScreen({required this.measurementId});

  @override
  _CalculatedStepsMultiVisualizationScreenState createState() =>
      _CalculatedStepsMultiVisualizationScreenState();
}

class _CalculatedStepsMultiVisualizationScreenState
    extends State<CalculatedStepsMultiVisualizationScreen> {
  // List of approaches with their asset paths.
  final List<Map<String, String>> approaches = [
    {
      "name": "Algorithm (SciPy Peak)",
      "filePath": "assets/calculated_steps_algo.json"
    },
    {
      "name": "CNN",
      "filePath": "assets/calculated_steps_CNN.json"
    },
    {
      "name": "GRU",
      "filePath": "assets/calculated_steps_GRU.json"
    },
    {
      "name": "LSTM 2 Layers",
      "filePath": "assets/calculated_steps_LSTM2Layers.json"
    },
    {
      "name": "LSTM Basic",
      "filePath": "assets/calculated_steps_LSTMBasic.json"
    },
    {
      "name": "RandomForest",
      "filePath": "assets/calculated_steps_RandomForest.json"
    },
    {
      "name": "XGBoost",
      "filePath": "assets/calculated_steps_XGBoost.json"
    },
  ];

  /// Loads the measurement for a given file that matches the measurementId.
  Future<Measurement?> loadMeasurementFromFile(
      String filePath, String measurementId) async {
    try {
      final String jsonString = await rootBundle.loadString(filePath);
      final List<Measurement> measurements =
          Measurement.fromJsonList(jsonString);
      // Find the measurement with the matching id.
      return measurements.firstWhere((m) => m.id == measurementId);
    } catch (e) {
      print("Error loading measurement from $filePath: $e");
      return null;
    }
  }

  /// Loads data from all approaches.
  Future<List<Map<String, dynamic>>> loadAllApproachData() async {
    List<Map<String, dynamic>> results = [];
    for (var approach in approaches) {
      Measurement? m =
          await loadMeasurementFromFile(approach["filePath"]!, widget.measurementId);
      results.add({
        "name": approach["name"],
        "measurement": m,
      });
    }
    return results;
  }

  /// Building a custom visualization widget for a measurement.
  /// It displays the time duration, the step counts (left/right),
  /// and then a horizontal bar where each side's width is proportional to its count.
  Widget buildCustomVisualization(Measurement measurement) {
    // Parse start and end times
    final DateTime start = DateTime.parse(measurement.startTime);
    final DateTime end = DateTime.parse(measurement.endTime);
    final int durationSec = end.difference(start).inSeconds;
    final int left = measurement.leftSteps;
    final int right = measurement.rightSteps;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Duration: $durationSec sec",
            style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text("Left: $left   Right: $right",
            style: TextStyle(fontSize: 14)),
        SizedBox(height: 8),
        // Custom horizontal bar visualization.
        Container(
          height: 20,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              // Left steps bar: using flex to scale proportionally.
              Expanded(
                flex: left,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                    ),
                  ),
                ),
              ),
              // Right steps bar:
              Expanded(
                flex: right,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calculated Steps Visualizations"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: loadAllApproachData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text("Error loading data"));
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return Center(child: Text("No data available"));

          final List<Map<String, dynamic>> approachesData = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: approachesData.map((data) {
                final String approachName = data["name"];
                final Measurement? m = data["measurement"];
                return Card(
                  margin: EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(approachName,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 8),
                        m != null
                            ? buildCustomVisualization(m)
                            : Text("No data available for this approach"),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
