# Tag-parser

Simple package that allows you parse text with predefined tags, and returns styled Flutter text.

## Available tags

None. Dart part of this package is agnostic to any semantics of tags.

### Basic tags

However, we provide a list of basic tags for quick use. Read more in [usage](#usage).

## Usage

* [MarkupTagStyle](#markuptagstyle) - define custom tag
* [DefaultMarkupStyle](#defaultmarkupstyle) - apply tags to descendant
* [MarkupText](#markuptext) - widget for markup text
  * [Use tags from ancestor `DefaultMarkupStyle`](#use-tags-from-ancestor-defaultmarkupstyle)
  * [Use predefined `DefaultMarkupStyle.basicTag`](#use-predefined-defaultmarkupstylebasictag)
  * [Use custom tags](#use-custom-tags)
  * [Overwrite tags from ancestor](#overwrite-tags-from-ancestor)
* [Example](#example) 

### MarkupTagStyle

Define custom tag and style using `MarkupTagStyle.delegate`. Pass tag name and desired style, e.g. to use tag [b] to apply `FontWeight.bold` to text do:

```dart
MarkupTagStyle.delegate(
    tagName: 'b',
    styleCreator: (_) => const TextStyle(fontWeight: FontWeight.bold),
),
```

### MarkupWrapSpanFactory

You could wrap your tagged text into any widgets. To do so, define tag factory for specified tag. Tag factory could be only defined in the tagFactories parameter in `DefaultMarkupStyle`, that take as argument Map of pairs `tag`:`MarkupWrapSpanFactory`. It's done like that, so there's a guarantee that every tag has only one factory.
`MarkupWrapSpanFactory` takes as parameters child `Widget`, that needs to be wraped with desired widgets and optional `parameter` taken from tag parsing.
It returns WidgetSpan.

### DefaultMarkupStyle

`DefaultMarkupStyle` is equivalent of well known `DefaultTextStyle`, but for the `MarkupTagStyle`. It apply markup tags styles to descendant `MarkupText` widgets. 
`DefaultMarkupStyle` also has `Map<String, MarkupWrapSpanFactory> tagFactories` parameter to wrap specified tagged text with Widgets.

```dart
DefaultMarkupStyle(
    tags: [
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

#### Use tags from ancestor `DefaultMarkupStyle`

```dart 
const MarkupText(
    '[u]underline[/u][i][b]Italic, bold text[/b][/i]',
),
```

#### Use predefined `DefaultMarkupStyle.basicTag`  

```dart 
MarkupText(
    '[u]underline[/u][i][b]Italic, bold text[/b][/i]',
    tags: DefaultMarkupStyle.basicTags,
),
```

#### Use custom tags

```dart 
MarkupText(
    '[green][u]underline[/u][/green][i][b]Italic, bold text[/b][/i]',
    tags: [
        MarkupTagStyle.delegate(
            tagName: 'green',
            styleCreator: (_) => const TextStyle(color: Colors.green),
        ),
    ],
),
```

#### Overwrite tags from ancestor
  
```dart 
DefaultMarkupStyle(
    tags: DefaultMarkupStyle.basicTags,
    child: MarkupText(
        '[u]underline[/u][i][b]Italic, bold text[/b][/i]',
        tags: [
            MarkupTagStyle.delegate(
                tagName: 'b',
                styleCreator: (_) => const TextStyle(fontWeight: FontWeight.w900),
            ),
        ],
    ),
),
```

## Example

This code shows an example of usage `DefaultMarkupStyle` and `MarkupText`.

```dart
Column(
  children: [
    // You can use `DefaultMarkupStyle` to define common tags for children.
    DefaultMarkupStyle(
        tags: DefaultMarkupStyle.basicTags,
        // Add tag factory to launch link passed in url tags
        tagFactories: {
            'url': (child, parameter) {
                return WidgetSpan(
                    child: GestureDetector(
                        onTap: () => launchUrl(Uri.parse(parameter!)),
                        child: child,
                    ),
                );
            },
        }
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
```

## TODOs:

1. Flutter tests
2. Optimize rendering. Some style computations can be cached/precomputed at `DefaultMarkupStyle` level
3. Better error reporting
