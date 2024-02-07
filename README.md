# Tag-parser

Simple package that allows you parse text with predefined tags, and returns styled Flutter text.

## Available tags

None. Dart part of this package is agnostic to any semantics of tags.

### Basic tag styles

However, we provide a list of basic tag styles for quick use. Read more in [usage](#usage).

## Usage

* [MarkupTagStyle](#markuptagstyle) - define custom tag style
* [DefaultMarkupTheme](#defaultmarkuptheme) - apply tag styles to descendant
* [MarkupText](#markuptext) - widget for markup text
  * [Use tag styles from ancestor `DefaultMarkupTheme`](#use-tag-styles-from-ancestor-defaultmarkupstyle)
  * [Use predefined `DefaultMarkupTheme.basicTag`](#use-predefined-defaultmarkupstylebasictag)
  * [Use custom tag styles](#use-custom-tag-styles)
  * [Overwrite tag styles from ancestor](#overwrite-tag-styles-from-ancestor)
  * [Escape tag](#escape-tag)
* [Example](#example) 

### MarkupTagStyle

Define custom tag and style using `MarkupTagStyle.delegate`. Pass tag name and desired style, e.g. to use tag [b] to apply `FontWeight.bold` to text do:

```dart
MarkupTagStyle.delegate(
    tagName: 'b',
    styleCreator: (_) => const TextStyle(fontWeight: FontWeight.bold),
),
```

### MarkupTagSpanFactory

You could wrap your tagged text into any widgets. To do so, define tag factory for specified tag. Tag factory could be only defined in the tagFactories parameter in `DefaultMarkupTheme`, that take as argument Map of pairs `tag`:`MarkupTagSpanFactory`. It's done like that, so there's a guarantee that every tag has only one factory.
`MarkupTagSpanFactory` takes as parameters child `Widget`, that needs to be wraped with desired widgets and optional `parameter` taken from tag parsing.
It returns WidgetSpan.

### DefaultMarkupTheme

`DefaultMarkupTheme` is equivalent of well known `DefaultTextStyle`, but for the `MarkupTagStyle`. It apply markup tag styles to descendant `MarkupText` widgets. 
`DefaultMarkupTheme` also has `Map<String, MarkupTagSpanFactory> tagFactories` parameter to wrap specified tagged text with Widgets.

```dart
DefaultMarkupTheme(
    tagStyles: [
        MarkupTagStyle.delegate(
            tagName: 'b',
            styleCreator: (_) => const TextStyle(fontWeight: FontWeight.bold),
        ),
        MarkupTagStyle.delegate(
            tagName: 'i',
            styleCreator: (_) => const TextStyle(fontStyle: FontStyle.italic),
        ),
    ],
    tagFactories: {
        'url': (child, parameter) {
            return WidgetSpan(
                child: GestureDetector(
                    onTap: () => launchUrl(Uri.parse(parameter!)),
                    child: child,
                ),
            );
        },
        ...
    }
    child: ...
),
```

### MarkupText

Converts passed `String` into `Text.rich` with applied `TextStyles`.

#### Use tag styles from ancestor `DefaultMarkupTheme`

```dart 
const MarkupText(
    '[u]underline[/u][i][b]Italic, bold text[/b][/i]',
),
```

#### Use predefined `DefaultMarkupTheme.basicTag`  

```dart 
MarkupText(
    '[u]underline[/u][i][b]Italic, bold text[/b][/i]',
    tagStyles: DefaultMarkupTheme.basicTags,
),
```

#### Use custom tag styles

```dart 
MarkupText(
    '[green][u]underline[/u][/green][i][b]Italic, bold text[/b][/i]',
    tagStyles: [
        MarkupTagStyle.delegate(
            tagName: 'green',
            styleCreator: (_) => const TextStyle(color: Colors.green),
        ),
    ],
),
```

#### Overwrite tag styles from ancestor
  
```dart 
DefaultMarkupTheme(
    tagStyles: DefaultMarkupTheme.basicTags,
    child: MarkupText(
        '[u]underline[/u][i][b]Italic, bold text[/b][/i]',
        tagStyles: [
            MarkupTagStyle.delegate(
                tagName: 'b',
                styleCreator: (_) => const TextStyle(fontWeight: FontWeight.w900),
            ),
        ],
    ),
),
```

#### Escape tag

```dart
Center(
  child: MarkupText(
    r'[u][i]Lorem ipsum dolor sit amet, \[b]consectetur adipiscing elit\[/b][/i][/u]',
    tagStyles: DefaultMarkupTheme.basicTags,
  ),
),
```

## Example

This code shows an example of usage `DefaultMarkupTheme` and `MarkupText`.

```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    // You can use `DefaultMarkupTheme` to define common tag styles for children.
    DefaultMarkupTheme(
      tagStyles: [
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
        MarkupTagStyle.delegate(
          tagName: 'yellow',
          styleCreator: (_) => const TextStyle(
            backgroundColor: Colors.black,
          ),
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
      },
      child: Column(
        children: [
          // Use tag styles from `DefaultMarkupTheme` parent
          const MarkupText(
            '[i]Lorem ipsum dolor sit amet, [b]consectetur adipiscing elit[/b][/i]',
          ),
          const SizedBox(height: 8),
          MarkupText(
            '[yellow][i]Lorem ipsum dolor sit amet, [b]consectetur adipiscing elit[/b][/i][/yellow]',
            tagStyles: [
              // You can add custom tag styles just for `MarkupText`.
              // The rest of the tag styles will still be taken from the parent.
              MarkupTagStyle.delegate(
                tagName: 'yellow',
                styleCreator: (_) =>
                    const TextStyle(color: Color(0xFFFEFF00)),
              ),
              // You can overwrite tag styles from `DefaultMarkupTheme` parent
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
        tagStyles: DefaultMarkupTheme.basicTags,
      ),
    ),
    const SizedBox(height: 8),
    // You can escape tags using "\".
    Center(
      child: MarkupText(
        r'[u][i]Lorem ipsum dolor sit amet, \[b]consectetur adipiscing elit\[/b][/i][/u]',
        tagStyles: DefaultMarkupTheme.basicTags,
      ),
    ),
  ],
),
```

## TODOs:

1. Flutter tests
2. Optimize rendering. Some style computations can be cached/precomputed at `DefaultMarkupTheme` level
3. Better error reporting
