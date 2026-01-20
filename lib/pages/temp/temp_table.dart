import 'package:flutter/material.dart';
import '../../widgets/app_data_table.dart';

class TempRow {
  final String id;
  final String temp;
  final String antId;
  final int times;
  final String pc;
  final String crc;
  final String epc;

  TempRow({
    required this.id,
    required this.temp,
    required this.antId,
    required this.times,
    required this.pc,
    required this.crc,
    required this.epc,
  });
}

class TempTable extends StatelessWidget {
  final List<TempRow> rows;

  const TempTable({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return AppDataTable(
      headers: const ['ID', 'Temp', 'Ant', 'Times', 'PC', 'CRC', 'EPC'],
      rows: rows.map((r) {
        return [
          Text(r.id),
          Text(
            r.temp,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(r.antId),
          Text(r.times.toString()),
          Text(r.pc),
          Text(r.crc),
          Text(r.epc),
        ];
      }).toList(),
    );
  }
}
