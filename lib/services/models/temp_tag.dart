class TempTag {
  final String epc;
  final String temp;
  final String antId;
  final String pc;
  final String crc;
  final int times; // 🔥 số lần quét / poll được

  const TempTag({
    required this.epc,
    required this.temp,
    required this.antId,
    required this.pc,
    required this.crc,
    this.times = 1,
  });

  TempTag copyWith({
    String? temp,
    String? antId,
    String? pc,
    String? crc,
    int? times,
  }) {
    return TempTag(
      epc: epc,
      temp: temp ?? this.temp,
      antId: antId ?? this.antId,
      pc: pc ?? this.pc,
      crc: crc ?? this.crc,
      times: times ?? this.times,
    );
  }

  factory TempTag.fromMap(Map<String, dynamic> map) {
    return TempTag(
      epc: map['epc']?.toString() ?? '',
      temp: map['temp']?.toString() ?? '--',
      antId: map['antId']?.toString() ?? '--',
      pc: map['pc']?.toString() ?? '--',
      crc: map['crc']?.toString() ?? '--',
    );
  }
}
