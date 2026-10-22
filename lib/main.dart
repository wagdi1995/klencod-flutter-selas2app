
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() =>
      _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String expression = '';
  String result = '0';

  final List<String> buttons = [
    'AC', '+/-', '%', '÷',
    '7', '8', '9', '×',
    '4', '5', '6', '-',
    '1', '2', '3', '+',
    '0', '.', '=', 
  ];

  void onPressed(String value) {
    setState(() {
      if (value == 'AC') {
        expression = '';
        result = '0';
      } else if (value == '+/-') {
        if (result != '0') {
          result = result.startsWith('-')
              ? result.substring(1)
              : '-$result';
          expression = result;
        }
      } else if (value == '%') {
        if (result != '0') {
          try {
            final number = double.parse(result);
            result = formatNumber(number / 100);
            expression = result;
          } catch (_) {}
        }
      } else if (value == '=') {
        calculate();
      } else {
        if (['+', '-', '×', '÷'].contains(value)) {
          if (expression.isEmpty && value != '-') return;

          if (expression.isNotEmpty &&
              ['+', '-', '×', '÷'].contains(
                expression[expression.length - 1])) {
            expression =
                expression.substring(0, expression.length - 1);
          }
        }

        if (value == '.') {
          final parts = expression.split(RegExp(r'[+\-×÷]'));
          if (parts.isNotEmpty && parts.last.contains('.')) {
            return;
          }
        }

        expression += value;
        result = expression;
      }
    });
  }

  void calculate() {
    if (expression.isEmpty) return;

    try {
      final formattedExpression = expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/');

      final parser = GrammarParser();
      final parsed = parser.parse(formattedExpression);
      final evaluator = RealEvaluator();
      final answer = evaluator.evaluate(parsed);

      result = formatNumber(answer);
      expression = result;
    } catch (_) {
      result = 'خطأ';
    }
  }

  String formatNumber(num number) {
    if (!number.isFinite) return 'خطأ';
    if (number == number.roundToDouble()) {
      return number.toInt().toString();
    }
    return number.toStringAsFixed(8)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  Color buttonColor(String value) {
    if (['÷', '×', '-', '+', '='].contains(value)) {
      return const Color(0xFFFF9F0A);
    }
    if (['AC', '+/-', '%'].contains(value)) {
      return const Color(0xFFA5A5A5);
    }
    return const Color(0xFF333333);
  }

  Color textColor(String value) {
    if (['AC', '+/-', '%'].contains(value)) {
      return Colors.black;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              const Spacer(flex: 3),

              SizedBox(
                width: double.infinity,
                child: Text(
                  expression,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 32,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    result,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 76,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              ...List.generate(5, (row) {
                final start = row * 4;
                final end = row == 4 ? 19 : start + 4;
                final rowButtons = buttons.sublist(start, end);

                return Expanded(
                  child: Row(
                    children: rowButtons.map((value) {
                      final isZero = value == '0';

                      return Expanded(
                        flex: isZero ? 2 : 1,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: SizedBox.expand(
                            child: Material(
                              color: buttonColor(value),
                              shape: const CircleBorder(),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () => onPressed(value),
                                child: Center(
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      color: textColor(value),
                                      fontSize: 29,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
