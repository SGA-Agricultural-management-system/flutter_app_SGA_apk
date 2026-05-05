class ActivityModel {
  final String id;
  final String type;
  final String lot;
  final String lotId;
  final String crop;
  final String quantity;
  final String unit;
  final DateTime date;
  final String? notes;
  final String farmId;
  final List<String> photoPaths;

  const ActivityModel({
    required this.id,
    required this.type,
    required this.lot,
    required this.crop,
    required this.quantity,
    required this.unit,
    required this.date,
    required this.farmId,
    this.lotId = '',
    this.notes,
    this.photoPaths = const [],
  });

  String get quantityDisplay => '$quantity $unit';
  String get lotDisplay      => '$lot${crop.isNotEmpty ? ' - $crop' : ''}';

  factory ActivityModel.fromJson(Map<String, dynamic> json) => ActivityModel(
        id:       json['id']?.toString()       ?? '',
        type:     json['type']    as String?   ?? '',
        lot:      json['lot']     as String?   ?? '',
        lotId:    json['lotId']?.toString()    ?? '',
        crop:     json['crop']    as String?   ?? '',
        quantity: json['quantity']?.toString() ?? '',
        unit:     json['unit']    as String?   ?? '',
        date:     json['date'] != null
            ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
            : DateTime.now(),
        notes:    json['notes']   as String?,
        farmId:   json['farmId']?.toString()   ?? '',
        photoPaths: (json['photoPaths'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ?? [],
      );

  Map<String, dynamic> toJson() => {
        'id':         id,
        'type':       type,
        'lot':        lot,
        'lotId':      lotId,
        'crop':       crop,
        'quantity':   quantity,
        'unit':       unit,
        'date':       date.toIso8601String(),
        'notes':      notes,
        'farmId':     farmId,
        'photoPaths': photoPaths,
      };
}

class ActivityType {
  static const String siembra       = 'SIEMBRA';
  static const String riego         = 'RIEGO';
  static const String fertilizacion = 'FERTILIZACION';
  static const String fumigacion    = 'FUMIGACION';
  static const String plagas        = 'CONTROL_PLAGAS';
  static const String cosecha       = 'COSECHA';
  static const String otro          = 'OTRO';

  static const List<String> all = [
    siembra, riego, fertilizacion, fumigacion, plagas, cosecha, otro,
  ];

  static String display(String type) {
    const map = {
      'SIEMBRA':        'Siembra',
      'RIEGO':          'Riego',
      'FERTILIZACION':  'Fertilización',
      'FUMIGACION':     'Fumigación',
      'CONTROL_PLAGAS': 'Control de Plagas',
      'COSECHA':        'Cosecha',
      'OTRO':           'Otro',
    };
    return map[type] ?? type;
  }
}
