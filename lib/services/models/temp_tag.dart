class TempTag {
  final String epc;
  final String temp;
  final String antId;
  final String pc;
  final String crc;

  TempTag({
    required this.epc,
    required this.temp,
    required this.antId,
    required this.pc,
    required this.crc,
  });

  factory TempTag.fromMap(Map<String, dynamic> map) {
    return TempTag(
      epc: map['epc']?.toString() ?? '',
      temp: map['temp']?.toString() ?? '',
      antId: map['antId']?.toString() ?? '',
      pc: map['pc']?.toString() ?? '',
      crc: map['crc']?.toString() ?? '',
    );
  }
}
