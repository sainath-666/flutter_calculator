import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF17171C),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4B5EFC),
          secondary: Color(0xFF2E2F38),
        ),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _expression = '';
  double _firstOperand = 0;
  String _operator = '';
  bool _shouldResetDisplay = false;
  final List<String> _history = [];

  void _onDigitPress(String digit) {
    setState(() {
      if (_display == '0' || _shouldResetDisplay) {
        _display = digit;
        _shouldResetDisplay = false;
      } else {
        if (_display.length < 12) {
          _display += digit;
        }
      }
    });
  }

  void _onDecimalPress() {
    setState(() {
      if (_shouldResetDisplay) {
        _display = '0.';
        _shouldResetDisplay = false;
      } else if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  void _onOperatorPress(String operator) {
    setState(() {
      _firstOperand = double.tryParse(_display) ?? 0;
      _operator = operator;
      _expression = '$_display $operator';
      _shouldResetDisplay = true;
    });
  }

  void _onEqualsPress() {
    if (_operator.isEmpty) return;

    double secondOperand = double.tryParse(_display) ?? 0;
    double result = 0;
    String initialExpression = '$_firstOperand $_operator $secondOperand';

    setState(() {
      switch (_operator) {
        case '+':
          result = _firstOperand + secondOperand;
          break;
        case '-':
          result = _firstOperand - secondOperand;
          break;
        case '×':
          result = _firstOperand * secondOperand;
          break;
        case '÷':
          if (secondOperand != 0) {
            result = _firstOperand / secondOperand;
          } else {
            _display = 'Error';
            _expression = '';
            _operator = '';
            return;
          }
          break;
      }

      // Format the result
      String resultString;
      if (result == result.toInt()) {
        resultString = result.toInt().toString();
      } else {
        resultString = result
            .toStringAsFixed(8)
            .replaceAll(RegExp(r'0+$'), '')
            .replaceAll(RegExp(r'\.$'), '');
      }

      _history.insert(0, '$initialExpression = $resultString');
      _display = resultString;

      // Limit display length
      if (_display.length > 12) {
        _display = result.toStringAsExponential(4);
      }

      _expression = '';
      _operator = '';
      _shouldResetDisplay = true;
    });
  }

  void _onClearPress() {
    setState(() {
      _display = '0';
      _expression = '';
      _firstOperand = 0;
      _operator = '';
      _shouldResetDisplay = false;
    });
  }

  void _onBackspacePress() {
    setState(() {
      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = '0';
      }
    });
  }

  void _onPercentPress() {
    setState(() {
      double value = double.tryParse(_display) ?? 0;
      value = value / 100;
      if (value == value.toInt()) {
        _display = value.toInt().toString();
      } else {
        _display = value.toString();
      }
      _shouldResetDisplay = true;
    });
  }

  void _onSignPress() {
    setState(() {
      if (_display != '0') {
        if (_display.startsWith('-')) {
          _display = _display.substring(1);
        } else {
          _display = '-$_display';
        }
      }
    });
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF17171C),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'History',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _history.isEmpty
                    ? const Center(
                        child: Text(
                          'No history yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              _history[index],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                String result = _history[index]
                                    .split(' = ')
                                    .last;
                                _display = result;
                                _shouldResetDisplay = true;
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Display Section
            Expanded(
              flex: 1,
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    alignment: Alignment.bottomRight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Expression display
                        if (_expression.isNotEmpty)
                          Text(
                            _expression,
                            style: const TextStyle(
                              fontSize: 32,
                              color: Color(0xFF747477),
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        const SizedBox(height: 16),
                        // Main display
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            _display,
                            style: const TextStyle(
                              fontSize: 96,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IconButton(
                      icon: const Icon(Icons.history, color: Colors.white),
                      onPressed: _showHistory,
                    ),
                  ),
                ],
              ),
            ),

            // Keypad Section
            Container(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildButtonRow([
                    _buildButton(
                      'C',
                      ButtonType.function,
                      onTap: _onClearPress,
                    ),
                    _buildButton('±', ButtonType.function, onTap: _onSignPress),
                    _buildButton(
                      '%',
                      ButtonType.function,
                      onTap: _onPercentPress,
                    ),
                    _buildButton(
                      '÷',
                      ButtonType.operator,
                      onTap: () => _onOperatorPress('÷'),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _buildButtonRow([
                    _buildButton(
                      '7',
                      ButtonType.number,
                      onTap: () => _onDigitPress('7'),
                    ),
                    _buildButton(
                      '8',
                      ButtonType.number,
                      onTap: () => _onDigitPress('8'),
                    ),
                    _buildButton(
                      '9',
                      ButtonType.number,
                      onTap: () => _onDigitPress('9'),
                    ),
                    _buildButton(
                      '×',
                      ButtonType.operator,
                      onTap: () => _onOperatorPress('×'),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _buildButtonRow([
                    _buildButton(
                      '4',
                      ButtonType.number,
                      onTap: () => _onDigitPress('4'),
                    ),
                    _buildButton(
                      '5',
                      ButtonType.number,
                      onTap: () => _onDigitPress('5'),
                    ),
                    _buildButton(
                      '6',
                      ButtonType.number,
                      onTap: () => _onDigitPress('6'),
                    ),
                    _buildButton(
                      '-',
                      ButtonType.operator,
                      onTap: () => _onOperatorPress('-'),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _buildButtonRow([
                    _buildButton(
                      '1',
                      ButtonType.number,
                      onTap: () => _onDigitPress('1'),
                    ),
                    _buildButton(
                      '2',
                      ButtonType.number,
                      onTap: () => _onDigitPress('2'),
                    ),
                    _buildButton(
                      '3',
                      ButtonType.number,
                      onTap: () => _onDigitPress('3'),
                    ),
                    _buildButton(
                      '+',
                      ButtonType.operator,
                      onTap: () => _onOperatorPress('+'),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _buildButtonRow([
                    _buildButton(
                      '⌫',
                      ButtonType.number,
                      onTap: _onBackspacePress,
                    ),
                    _buildButton(
                      '0',
                      ButtonType.number,
                      onTap: () => _onDigitPress('0'),
                    ),
                    _buildButton(
                      '.',
                      ButtonType.number,
                      onTap: _onDecimalPress,
                    ),
                    _buildButton('=', ButtonType.equals, onTap: _onEqualsPress),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonRow(List<Widget> buttons) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: buttons,
    );
  }

  Widget _buildButton(
    String text,
    ButtonType type, {
    required VoidCallback onTap,
  }) {
    Color backgroundColor;
    Color textColor = Colors.white;
    double fontSize = 32;

    switch (type) {
      case ButtonType.number:
        backgroundColor = const Color(0xFF2E2F38); // Dark Grey
        break;
      case ButtonType.operator:
        backgroundColor = const Color(0xFF4B5EFC); // Electric Blue
        break;
      case ButtonType.function:
        backgroundColor = const Color(0xFF4E505F); // Light Grey
        break;
      case ButtonType.equals:
        backgroundColor = const Color(0xFF4B5EFC); // Electric Blue
        break;
    }

    return SizedBox(
      width: 72,
      height: 72,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w400,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum ButtonType { number, operator, function, equals }
