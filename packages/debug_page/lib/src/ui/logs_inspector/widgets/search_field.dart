import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.onChanged,
  });

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        labelText: 'Search',
        icon: Icon(Icons.search),
      ),
    );
  }
}
