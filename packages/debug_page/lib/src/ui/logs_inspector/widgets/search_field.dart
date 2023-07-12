import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.initialPhrase,
    required this.onChanged,
  });

  final String initialPhrase;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialPhrase,
      onChanged: onChanged,
      decoration: const InputDecoration(
        border: UnderlineInputBorder(),
        labelText: 'Search',
        icon: Icon(Icons.search),
      ),
    );
  }
}
