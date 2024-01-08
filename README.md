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

### DefaultMarkupStyle

`DefaultMarkupStyle` is equivalent of well known `DefaultTextStyle`, but for the `MarkupTagStyle`. It apply markup tags styles to descendant `MarkupText` widgets. 

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
2. Add support for tags: `url` and `sup`
3. Optimize rendering. Some style computations can be cached/precomputed at `DefaultMarkupStyle` level
4. Better error reporting

### Internal conflu docs:

- "Text styling syntax in Flutter brainstorm"
- "Text styling syntax research"
