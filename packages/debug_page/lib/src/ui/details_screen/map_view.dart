import 'package:flutter/material.dart';

class MapView extends StatelessWidget {
  const MapView({
    super.key,
    required this.map,
  });

  final Map<Object, Object> map;

  @override
  Widget build(BuildContext context) {
    return Table(
      children: map.entries.map(
        (entry) {
          return TableRow(children: [
            Text(entry.key.toString()),
            Text(entry.value.toString()),
          ]);
        },
      ).toList(),
    );
  }
}
