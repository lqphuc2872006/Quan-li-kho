import 'package:flutter/material.dart';


class InventoryRow {
  final int no;
  final String tagId;
  final String rssi;
  final String time;
  final String status;

  InventoryRow({
    required this.no,
    required this.tagId,
    required this.rssi,
    required this.time,
    required this.status,
  });
}


class InventoryTable extends StatelessWidget {
  final List<InventoryRow> rows;

  const InventoryTable({
    super.key,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 48,
        dataRowHeight: 44,
        columnSpacing: 24,
        headingTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
        columns: const [
          DataColumn(label: Text('No')),
          DataColumn(label: Text('Tag ID')),
          DataColumn(label: Text('RSSI')),
          DataColumn(label: Text('Time')),
          DataColumn(label: Text('Status')),
        ],
        rows: rows.map((row) {
          return DataRow(
            cells: [
              DataCell(Text(row.no.toString())),
              DataCell(Text(row.tagId)),
              DataCell(Text(row.rssi)),
              DataCell(Text(row.time)),
              DataCell(
                Text(
                  row.status,
                  style: TextStyle(
                    color: row.status == 'OK'
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
