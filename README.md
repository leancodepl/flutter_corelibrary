# Tag-parser

Simple package that allows you parse text with predefined tags, and returns styled Flutter text.


## What's done so far

- Lexer (lexer.dart) - parses input text and converts it to list of `TextToken()` and `OpenAndCloseToken()`.

- MarkDownParser (markdown_parser.dart) - takes `List<Token>` returns structure `TextWithAttributes` containing 'Text' and set of `Attributes` like `Bold(), Italic()` etc.

- Tests (markdown_tests.dart): contains two test groups: lexer tests, and parser tests.


## Avaliable tags

- Bold [b] Bolded text [/b]

- Italic [i] Italicized text [/i]

- Underlined [u] Underlined text [/u]

- Strikethrough [s] Strikethrough text [/s]


## TODOs:

1. To avoid defining `OpenClosedTokens` and `Attributes` (twice for same tag) and mapping one to another, lexer should return only `TextAttribute` + `OpenClosedToken` containing specific tag lettes e.x. `OpenCloseToken([b])`.
Parser should accept list of acceptable tags as input.
Each tag should have defined how is reflected in LNCDText class.

2. Parser should be able to identify closing and opening tokens and return `TextWithAttributes`.

3. After changing how lexer and parser work, rewrite tests:

<img width="441" alt="image" src="https://user-images.githubusercontent.com/114619093/206199389-95564764-6733-4cd8-851c-59b0b4081724.png">

3. Add parsing URL tag with:
- Text same as href
- Text other than href

4. Map `TextWithAttributes` to LNCDText class, and allow defining set of TextStyles per project.

### Internal conflu docs:
- "Text styling syntax in Flutter brainstorm"
- "Text styling syntax research"



