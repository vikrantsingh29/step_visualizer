import 'dart:convert';

class SensorMetadata {
  final String side;

  SensorMetadata({required this.side});

  factory SensorMetadata.fromJson(Map<String, dynamic> json) {
    return SensorMetadata(
      side: json['side'] ?? '',
    );
  }
}

class SensorData {
  final DateTime time;
  final SensorMetadata metadata;
  final double gx;
  final double ay;
  final double az;
  final double ax;
  final double gz;
  final double gy;

  SensorData({
    required this.time,
    required this.metadata,
    required this.gx,
    required this.ay,
    required this.az,
    required this.ax,
    required this.gz,
    required this.gy,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      time: DateTime.parse(json['time']),
      metadata: SensorMetadata.fromJson(json['metadata']),
      gx: (json['gx'] as num).toDouble(),
      ay: (json['ay'] as num).toDouble(),
      az: (json['az'] as num).toDouble(),
      ax: (json['ax'] as num).toDouble(),
      gz: (json['gz'] as num).toDouble(),
      gy: (json['gy'] as num).toDouble(),
    );
  }

  static List<SensorData> fromJsonList(String jsonString) {
    final data = json.decode(jsonString) as List;
    return data.map((item) => SensorData.fromJson(item)).toList();
  }
}
