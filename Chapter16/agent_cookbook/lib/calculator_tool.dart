import 'dart:convert';
import 'package:math_expressions/math_expressions.dart';
import 'tool.dart';

class CalculatorTool extends Tool {
  @override
  String get name => 'calculate';

  @override
  String get description =>
      'Evaluate a math expression. Supports '
      '+, -, *, /, ^, parentheses, and functions '
      'such as sqrt, sin, cos, and log.';

  @override
  Map<String, dynamic> get parameters => {
        'type': 'object',
        'properties': {
          'expression': {
            'type': 'string',
            'description':
                'The math expression, '
                'e.g. "(12 + 8) * 3"',
          },
        },
        'required': ['expression'],
      };

  @override
  Future<String> execute(
    Map<String, dynamic> input,
  ) async {
    final expr = input['expression'] as String;
    try {
      final ExpressionParser parser = GrammarParser();
      final result = RealEvaluator().evaluate(parser.parse(expr));
      return jsonEncode({'expression': expr, 'result': result});
    } catch (e) {
      return jsonEncode({
        'expression': expr,
        'error': 'Could not evaluate: $e',
      });
    }
  }
}
