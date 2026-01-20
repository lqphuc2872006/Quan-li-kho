import 'package:flutter/material.dart';

class AppDataTable extends StatelessWidget {
  final List<String> headers;
  final List<List<Widget>> rows;

  const AppDataTable({
    super.key,
    required this.headers,
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
        columns: headers
            .map((h) => DataColumn(label: Text(h)))
            .toList(),
        rows: rows
            .map(
              (cells) => DataRow(
            cells: cells.map((c) => DataCell(c)).toList(),
          ),
        )
            .toList(),
      ),
    );
  }
}
