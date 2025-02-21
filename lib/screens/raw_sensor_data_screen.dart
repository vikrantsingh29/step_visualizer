import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/sensor_data.dart';
import '../services/sensor_loader.dart';

class RawSensorDataScreen extends StatefulWidget {
  final String measurementId;

  RawSensorDataScreen({required this.measurementId});

  @override
  _RawSensorDataScreenState createState() => _RawSensorDataScreenState();
}

class _RawSensorDataScreenState extends State<RawSensorDataScreen> {
  late Future<List<SensorData>> rawData;

  @override
  void initState() {
    super.initState();
    rawData = SensorLoader.loadSensorData(widget.measurementId);
  }

  /// Helper: Build a line chart for a given field extractor.
  Widget buildLineChartForField({
    required List<SensorData> sensorData,
    required double Function(SensorData) extractor,
    required String title,
    required Color color,
  }) {
    if (sensorData.isEmpty) return Container();
    final startTime = sensorData.first.time;
    List<FlSpot> spots = [];
    for (int i = 0; i < sensorData.length; i++) {
      double t = sensorData[i].time.difference(startTime).inMilliseconds / 1000.0;
      spots.add(FlSpot(t, extractor(sensorData[i])));
    }
    double minY = spots.map((s) => s.y).reduce(min) - 0.5;
    double maxY = spots.map((s) => s.y).reduce(max) + 0.5;
    double maxX = sensorData.last.time.difference(startTime).inMilliseconds / 1000.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: maxX,
              minY: minY,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: color,
                  barWidth: 2,
                  dotData: FlDotData(show: false),
                ),
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) => Text('${value.toStringAsFixed(1)}s', style: TextStyle(fontSize: 10)),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) => Text(value.toStringAsFixed(1), style: TextStyle(fontSize: 10)),
                  ),
                ),
              ),
              gridData: FlGridData(show: true),
            ),
          ),
        ),
      ],
    );
  }

  /// Build a chart for acceleration magnitude: sqrt(ax^2+ay^2+az^2)
  Widget buildAccelMagnitudeChart(List<SensorData> sensorData) {
    return buildLineChartForField(
      sensorData: sensorData,
      extractor: (d) => sqrt(pow(d.ax, 2) + pow(d.ay, 2) + pow(d.az, 2)),
      title: "Acceleration Magnitude",
      color: Colors.blue,
    );
  }

  /// Build a chart for gyroscope magnitude: sqrt(gx^2+gy^2+gz^2)
  Widget buildGyroMagnitudeChart(List<SensorData> sensorData) {
    return buildLineChartForField(
      sensorData: sensorData,
      extractor: (d) => sqrt(pow(d.gx, 2) + pow(d.gy, 2) + pow(d.gz, 2)),
      title: "Gyroscope Magnitude",
      color: Colors.red,
    );
  }

  /// Build a scatter chart for metadata "side".
  /// For each sensor data point, plot at y=1 for "L" and y=0 for "R".
  Widget buildSideScatterChart(List<SensorData> sensorData) {
    if (sensorData.isEmpty) return Container();
    final startTime = sensorData.first.time;
    List<ScatterSpot> spots = [];
    for (int i = 0; i < sensorData.length; i++) {
      double t = sensorData[i].time.difference(startTime).inMilliseconds / 1000.0;
      // Use y = 1 for left, y = 0 for right (you can adjust these values)
      double y = sensorData[i].metadata.side.toUpperCase() == "L" ? 1.0 : 0.0;
      // Choose shape and color based on side.
      spots.add(ScatterSpot(t, y,
          color: sensorData[i].metadata.side.toUpperCase() == "L" ? Colors.green : Colors.orange,
          radius: 6));
    }
    double maxX = sensorData.last.time.difference(startTime).inMilliseconds / 1000.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Sensor Side (L vs R)", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: ScatterChart(
            ScatterChartData(
              scatterSpots: spots,
              minX: 0,
              maxX: maxX,
              minY: -0.5,
              maxY: 1.5,
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) => Text('${value.toStringAsFixed(1)}s', style: TextStyle(fontSize: 10)),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      if (value == 1)
                        return Text("L", style: TextStyle(fontSize: 10));
                      else if (value == 0)
                        return Text("R", style: TextStyle(fontSize: 10));
                      else
                        return Container();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Raw Sensor Data: ${widget.measurementId}'),
      ),
      body: FutureBuilder<List<SensorData>>(
        future: rawData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Error loading raw sensor data'));
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return Center(child: Text('No sensor data available'));
          final data = snapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Two magnitude charts:
                  buildAccelMagnitudeChart(data),
                  SizedBox(height: 16),
                  buildGyroMagnitudeChart(data),
                  SizedBox(height: 16),
                  // Individual line charts for each axis:
                  buildLineChartForField(
                    sensorData: data,
                    extractor: (d) => d.ax,
                    title: "Acceleration x (ax)",
                    color: Colors.blueAccent,
                  ),
                  SizedBox(height: 16),
                  buildLineChartForField(
                    sensorData: data,
                    extractor: (d) => d.ay,
                    title: "Acceleration y (ay)",
                    color: Colors.lightBlue,
                  ),
                  SizedBox(height: 16),
                  buildLineChartForField(
                    sensorData: data,
                    extractor: (d) => d.az,
                    title: "Acceleration z (az)",
                    color: Colors.indigo,
                  ),
                  SizedBox(height: 16),
                  buildLineChartForField(
                    sensorData: data,
                    extractor: (d) => d.gx,
                    title: "Gyroscope x (gx)",
                    color: Colors.redAccent,
                  ),
                  SizedBox(height: 16),
                  buildLineChartForField(
                    sensorData: data,
                    extractor: (d) => d.gy,
                    title: "Gyroscope y (gy)",
                    color: Colors.deepOrange,
                  ),
                  SizedBox(height: 16),
                  buildLineChartForField(
                    sensorData: data,
                    extractor: (d) => d.gz,
                    title: "Gyroscope z (gz)",
                    color: Colors.red,
                  ),
                  // SizedBox(height: 16),
                  // // Scatter chart for metadata side.
                  // buildSideScatterChart(data),
                  // SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
