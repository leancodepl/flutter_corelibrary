# Tag-parser

Simple package that allows you parse text with predefined tags, and returns styled Flutter text.

## What's done so far

- Lexer (`lexer.dart`) - parses input text and converts it to list of `Token`s: `text`, `tagOpen`, `tagOpen`.

- Parser (`parser.dart`) - takes `Tokens` returns a list of `TaggedText`s containing 'text' and a set of `Tag`s (name of the tag and a possible parameter).

- Flutter text renderer - given some supported tags and some markup text, it is rendered using the provided styles

- Tests - lexer and parser is tested

## Available tags

None. Dart part of this package is agnostic to any semantics of tags.

## TODOs:

1. Flutter tests
2. Add some base supported tags (`i`, `b`, `u`, etc.)
3. Optimize rendering. Some style computations can be cached/precomputed at `DefaultMarkupStyle` level
4. Better error reporting

### Internal conflu docs:

- "Text styling syntax in Flutter brainstorm"
- "Text styling syntax research"
