import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/measurement.dart';

class CalculatedStepsScreen extends StatelessWidget {
  final Measurement measurement;

  CalculatedStepsScreen({required this.measurement});

  @override
  Widget build(BuildContext context) {
    // Parse the start and end times to compute the duration.
    final DateTime start = DateTime.parse(measurement.startTime);
    final DateTime end = DateTime.parse(measurement.endTime);
    final Duration duration = end.difference(start);

    return Scaffold(
      appBar: AppBar(
        title: Text('Calculated Steps: ${measurement.id}'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display time duration
            Text(
              'Time Duration: ${duration.inSeconds} seconds',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            // Display the steps counts as text for clarity
            Text(
              'Left Steps: ${measurement.leftSteps}',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              'Right Steps: ${measurement.rightSteps}',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 24),
            Text(
              'Steps Count Visualization',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // Bar chart for visualizing left vs. right steps
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
                          switch (value.toInt()) {
                            case 0:
                              return Text('Left', style: TextStyle(fontSize: 12));
                            case 1:
                              return Text('Right', style: TextStyle(fontSize: 12));
                            default:
                              return Container();
                          }
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
      ),
    );
  }
}
