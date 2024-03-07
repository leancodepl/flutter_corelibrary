import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:leancode_markup/src/parser/lexer.dart';

class LexerBench extends BenchmarkBase {
  const LexerBench() : super('Lexer');

  static const _input = 'bb[i][b]Italic, bold text[/b][/i]';

  @override
  void run() {
    lexer.parse(_input);
  }

  @override
  void exercise() => run();
}
