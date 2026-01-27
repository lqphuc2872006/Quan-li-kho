class InventoryTag {
  final String epc;
  final String rssi;
  final String timestamp;
  final int count;

  InventoryTag({
    required this.epc,
    required this.rssi,
    required this.timestamp,
    this.count = 1,
  });

  factory InventoryTag.fromMap(Map<String, dynamic> map) {
    String time;

    if (map['timestamp'] is int) {
      time = DateTime.fromMillisecondsSinceEpoch(map['timestamp'])
          .toString()
          .substring(11, 19);
    } else {
      time = map['timestamp']?.toString() ??
          DateTime.now().toString().substring(11, 19);
    }

    return InventoryTag(
      epc: map['epc']?.toString() ?? '',
      rssi: map['rssi']?.toString() ?? '',
      timestamp: time,
      count: map['count'] ?? 1,
    );
  }
}