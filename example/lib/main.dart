import 'package:flutter/material.dart';
import 'package:leancode_markup/leancode_markup.dart';
import 'package:url_launcher/url_launcher.dart';

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
                MarkupTagStyle.delegate(
                  tagName: 'url',
                  styleCreator: (_) => const TextStyle(color: Colors.lightBlue),
                ),
              ],
              // Add tag factories to wrap your tagged text into any widget
              tagFactories: {
                'url': (child, parameter) {
                  return WidgetSpan(
                    child: GestureDetector(
                      onTap: () async {
                        if (parameter != null &&
                            await canLaunchUrl(Uri.parse(parameter))) {
                          await launchUrl(Uri.parse(parameter));
                        }
                      },
                      child: child,
                    ),
                  );
                },
                'sup': (child, parameter) {
                  return WidgetSpan(
                    child: Transform.translate(
                      offset: const Offset(2, -4),
                      child: child,
                    ),
                  );
                },
              },
              child: Column(
                children: [
                  const MarkupText(
                    '[u]underline[/u][i][b]Italic, bold text[url="https://google.com"][sup]go[/sup][u]ogle[/u][/url][/b][/i]',
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
