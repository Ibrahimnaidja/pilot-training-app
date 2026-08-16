import 'package:flutter/material.dart';

class DataTableGrid extends StatelessWidget {
  final List<String> categories;
  final List<String> periods;
  final List<List<int>> values; // values[categoryIndex][periodIndex]

  const DataTableGrid({super.key, required this.categories, required this.periods, required this.values});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final headerStyle = TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: scheme.onSurfaceVariant);
    final cellStyle = TextStyle(fontSize: 12, color: scheme.onSurface);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(color: scheme.outlineVariant, width: 0.6),
        defaultColumnWidth: const IntrinsicColumnWidth(),
        children: [
          TableRow(
            decoration: BoxDecoration(color: scheme.surfaceContainerHighest),
            children: [
              _cell('', headerStyle),
              for (final p in periods) _cell(p, headerStyle),
            ],
          ),
          for (var c = 0; c < categories.length; c++)
            TableRow(
              children: [
                _cell(categories[c], headerStyle),
                for (var p = 0; p < periods.length; p++) _cell('${values[c][p]}', cellStyle),
              ],
            ),
        ],
      ),
    );
  }

  Widget _cell(String text, TextStyle style) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Text(text, style: style, textAlign: TextAlign.center),
      );
}
