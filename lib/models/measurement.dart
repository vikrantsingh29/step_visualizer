import 'dart:convert';

class Measurement {
  final String id;
  final String startTime;
  final String endTime;
  final int leftSteps;
  final int rightSteps;

  Measurement({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.leftSteps,
    required this.rightSteps,
  });

  factory Measurement.fromJson(Map<String, dynamic> json) {
    return Measurement(
      id: json['measurement_id'] ?? 'Unknown',
      startTime: json['start_time'] ?? 'Unknown',
      endTime: json['end_time'] ?? 'Unknown',
      leftSteps: json['left_steps'] ?? 0,
      rightSteps: json['right_steps'] ?? 0,
    );
  }

  static List<Measurement> fromJsonList(String jsonString) {
    final data = json.decode(jsonString) as List;
    return data.map((item) => Measurement.fromJson(item)).toList();
  }
}
