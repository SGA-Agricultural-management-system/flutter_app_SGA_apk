class FarmModel {
  final String id;
  final String name;
  final String location;
  final List<LotModel> lots;

  const FarmModel({
    required this.id,
    required this.name,
    required this.location,
    this.lots = const [],
  });

  factory FarmModel.fromJson(Map<String, dynamic> json) => FarmModel(
        id:       json['id']?.toString()      ?? '',
        name:     json['name']   as String?   ?? '',
        location: json['location'] as String? ?? '',
        lots: (json['lots'] as List<dynamic>?)
                ?.map((l) => LotModel.fromJson(l as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class LotModel {
  final String id;
  final String name;
  final String crop;

  const LotModel({
    required this.id,
    required this.name,
    required this.crop,
  });

  String get display => '$name - $crop';

  factory LotModel.fromJson(Map<String, dynamic> json) => LotModel(
        id:   json['id']?.toString()    ?? '',
        name: json['name'] as String?   ?? '',
        crop: json['crop'] as String?   ?? '',
      );
}

class SensorDataModel {
  final double temperature;
  final double humidity;
  final DateTime updatedAt;

  const SensorDataModel({
    required this.temperature,
    required this.humidity,
    required this.updatedAt,
  });

  factory SensorDataModel.fromJson(Map<String, dynamic> json) => SensorDataModel(
        temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
        humidity:    (json['humidity']    as num?)?.toDouble() ?? 0.0,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );

  /// Datos mock para usar mientras no hay backend
  factory SensorDataModel.mock() => SensorDataModel(
        temperature: 24.0,
        humidity:    68.0,
        updatedAt:   DateTime.now(),
      );
}
