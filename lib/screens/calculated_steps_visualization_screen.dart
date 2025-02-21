import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/measurement.dart';

class CalculatedStepsVisualizationScreen extends StatelessWidget {
  final String filePath;
  final String architectureName;

  CalculatedStepsVisualizationScreen({required this.filePath, required this.architectureName});

  Future<List<Measurement>> loadMeasurements() async {
    final jsonString = await rootBundle.loadString(filePath);
    return Measurement.fromJsonList(jsonString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calculated Steps - $architectureName"),
      ),
      body: FutureBuilder<List<Measurement>>(
        future: loadMeasurements(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text("Error loading data"));
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return Center(child: Text("No data available"));

          // For demonstration, show the first measurement in the file.
          final measurement = snapshot.data!.first;
          final start = DateTime.parse(measurement.startTime);
          final end = DateTime.parse(measurement.endTime);
          final duration = end.difference(start);

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Measurement ID: ${measurement.id}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Duration: ${duration.inSeconds} seconds"),
                SizedBox(height: 16),
                Text("Left Steps: ${measurement.leftSteps}", style: TextStyle(fontSize: 14)),
                Text("Right Steps: ${measurement.rightSteps}", style: TextStyle(fontSize: 14)),
                SizedBox(height: 16),
                Text("Steps Visualization", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(
                              fromY: 0,
                              toY: measurement.leftSteps.toDouble(),
                              color: Colors.blue,
                              width: 20,
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              fromY: 0,
                              toY: measurement.rightSteps.toDouble(),
                              color: Colors.red,
                              width: 20,
                            ),
                          ],
                        ),
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(value.toInt() == 0 ? 'Left' : 'Right', style: TextStyle(fontSize: 12));
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(value.toStringAsFixed(0), style: TextStyle(fontSize: 12));
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(show: true),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
