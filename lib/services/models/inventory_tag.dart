class InventoryTag {
  final String epc;
  final String rssi;
  final DateTime lastSeen;
  final int count;

  const InventoryTag({
    required this.epc,
    required this.rssi,
    required this.lastSeen,
    this.count = 1,
  });

  // 🔁 COPY
  InventoryTag copyWith({
    String? rssi,
    DateTime? lastSeen,
    int? count,
  }) {
    return InventoryTag(
      epc: epc,
      rssi: rssi ?? this.rssi,
      lastSeen: lastSeen ?? this.lastSeen,
      count: count ?? this.count,
    );
  }

  // 🏭 FROM RFID
  factory InventoryTag.fromMap(Map<String, dynamic> map) {
    DateTime time;

    final rawTime = map['timestamp'];
    if (rawTime is int) {
      time = DateTime.fromMillisecondsSinceEpoch(rawTime);
    } else {
      time = DateTime.now();
    }

    return InventoryTag(
      epc: map['epc']?.toString() ?? '',
      rssi: map['rssi']?.toString() ?? '',
      lastSeen: time,
    );
  }

  // 🎨 UI HELPER
  String get displayTime =>
      lastSeen.toString().substring(11, 19);
}
