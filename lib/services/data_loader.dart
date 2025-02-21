import 'package:flutter/services.dart' show rootBundle;
import '../models/measurement.dart';

class DataLoader {
  static Future<List<Measurement>> loadMeasurements() async {
    // Use one of the new files as the source, e.g.:
    final String jsonString = await rootBundle.loadString('assets/calculated_steps_algo.json');
    return Measurement.fromJsonList(jsonString);
  }
}
