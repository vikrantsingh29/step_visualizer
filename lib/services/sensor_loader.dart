import 'package:flutter/services.dart' show rootBundle;
import '../models/sensor_data.dart';

class SensorLoader {
  // Loads sensor data file by measurement id.
  static Future<List<SensorData>> loadSensorData(String measurementId) async {
    final String jsonString = await rootBundle.loadString('assets/RawSensorData/$measurementId.json');
    return SensorData.fromJsonList(jsonString);
  }
}
