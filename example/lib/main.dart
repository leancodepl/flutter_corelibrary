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
          backgroundColor: Colors.white,
          title: MarkupText(
            '[appbar]tag-parser example app[/appbar]',
            tags: [
              MarkupTagStyle.delegate(
                tagName: 'appbar',
                styleCreator: (_) => const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                // Make clickable link
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
                // Transform text
                'sup': (child, parameter) {
                  return WidgetSpan(
                    child: Transform.translate(
                      offset: const Offset(2, -4),
                      child: child,
                    ),
                  );
                },
                // Add custom text background
                'yellow': (child, parameter) {
                  return WidgetSpan(
                    child: Container(
                      color: Colors.black,
                      child: child,
                    ),
                  );
                },
              },
              child: Column(
                children: [
                  // Use tags from `DefaultMarkupStyle` parent
                  const MarkupText(
                    '[i]Lorem ipsum dolor sit amet, [b]consectetur adipiscing elit[/b][/i]',
                  ),
                  const SizedBox(height: 8),
                  MarkupText(
                    '[yellow][i]Lorem ipsum dolor sit amet, [b]consectetur adipiscing elit[/b][/i][/yellow]',
                    tags: [
                      // You can add custom tags just for `MarkupText`.
                      // The rest of the tags will still be taken from the parent.
                      MarkupTagStyle.delegate(
                        tagName: 'yellow',
                        styleCreator: (_) =>
                            const TextStyle(color: Color(0xFFFEFF00)),
                      ),
                      // You can overwrite tags from `DefaultMarkupStyle` parent
                      MarkupTagStyle.delegate(
                        tagName: 'b',
                        styleCreator: (_) =>
                            const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Use tag factories to create e.g. clickable text to open link
                  const MarkupText(
                    '[url="https://leancode.co"][i]Lorem ipsum dolor sit amet, [b]consectetur adipiscing elit[/b][/i][/url]',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // You can use `basicTags` just in `MarkupText` widget.
            Center(
              child: MarkupText(
                '[u][i]Lorem ipsum dolor sit amet, [b]consectetur adipiscing elit[/b][/i][/u]',
                tags: DefaultMarkupStyle.basicTags,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
