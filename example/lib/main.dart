import 'package:flutter/material.dart';
import 'package:leancode_markup/leancode_markup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('tag-parser example app'),
        ),
        body: Column(
          children: [
            // You can use `DefaultMarkupStyle` to define common tags for children.
            DefaultMarkupStyle(
              tags: [
                MarkupTagStyle.delegate(
                  tagName: 'b',
                  styleCreator: (_) =>
                      const TextStyle(fontWeight: FontWeight.bold),
                ),
                MarkupTagStyle.delegate(
                  tagName: 'i',
                  styleCreator: (_) =>
                      const TextStyle(fontStyle: FontStyle.italic),
                ),
                MarkupTagStyle.delegate(
                  tagName: 'u',
                  styleCreator: (_) =>
                      const TextStyle(decoration: TextDecoration.underline),
                ),
              ],
              child: Column(
                children: [
                  const MarkupText(
                    '[u]underline[/u][i][b]Italic, bold text[/b][/i]',
                  ),
                  MarkupText(
                    '[green][u]underline[/u][/green][i][b]Italic, bold text[/b][/i]',
                    tags: [
                      // You can add custom tags just for `MarkupText`.
                      // The rest of the tags will still be taken from the parent.
                      MarkupTagStyle.delegate(
                        tagName: 'green',
                        styleCreator: (_) =>
                            const TextStyle(color: Colors.green),
                      ),
                      // You can overwrite tags from `DefaultMarkupStyle` parent
                      MarkupTagStyle.delegate(
                        tagName: 'b',
                        styleCreator: (_) =>
                            const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // You can use `basicTags` just in `MarkupText` widget.
            Center(
              child: MarkupText(
                '[u]underline[/u][i][b]Italic, bold text[/b][/i]',
                tags: DefaultMarkupStyle.basicTags,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
