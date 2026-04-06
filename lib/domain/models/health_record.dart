class HealthRecord {
  const HealthRecord({
    required this.id,
    required this.type,
    required this.value,
    required this.unit,
    required this.timestamp,
  });

  final String id;
  final String type;
  final String value;
  final String unit;
  final DateTime timestamp;

  HealthRecord copyWith({
    String? id,
    String? type,
    String? value,
    String? unit,
    DateTime? timestamp,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      type: type ?? this.type,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'type': type,
      'value': value,
      'unit': unit,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'] as String? ?? '',
      type: map['type'] as String? ?? '',
      value: map['value'] as String? ?? '',
      unit: map['unit'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.now(),
    );
  }
}
