import 'package:flutter/material.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CalculatorApp',
      theme: ThemeData.dark(), // Dark theme similar to Apple’s calculator.
      home: CalculatorPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalculatorPage extends StatefulWidget {
  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  String _operand1 = '';
  String _operator = '';
  bool _shouldResetDisplay = false;
  List<String> _history = [];

  // Handles button presses.
  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        // Clear current calculation.
        _display = '0';
        _operand1 = '';
        _operator = '';
      } else if (value == '+' || value == '-' || value == '×' || value == '÷') {
        // If an operator is already set, perform a chained calculation.
        if (_operator.isEmpty) {
          _operator = value;
          _operand1 = _display;
          _shouldResetDisplay = true;
        } else {
          _calculate();
          _operator = value;
          _operand1 = _display;
          _shouldResetDisplay = true;
        }
      } else if (value == '=') {
        // Only calculate if a valid operator and first operand exist.
        if (_operator.isNotEmpty && _operand1.isNotEmpty) {
          String expression = "$_operand1 $_operator $_display";
          _calculate();
          // Only add to history if no error occurred.
          if (_display != 'Error') {
            _history.add("$expression = $_display");
          }
          _operator = '';
        }
      } else {
        // Handling numbers and the decimal point.
        if (_shouldResetDisplay || _display == '0') {
          _display = '';
          _shouldResetDisplay = false;
        }
        // Prevent multiple decimals in one number.
        if (value == '.' && _display.contains('.')) {
          return;
        }
        _display += value;
      }
    });
  }

  // Performs arithmetic based on the current operands and operator.
  void _calculate() {
    double num1 = double.tryParse(_operand1) ?? 0;
    double num2 = double.tryParse(_display) ?? 0;
    double result = 0;

    switch (_operator) {
      case '+':
        result = num1 + num2;
        break;
      case '-':
        result = num1 - num2;
        break;
      case '×':
        result = num1 * num2;
        break;
      case '÷':
        if (num2 == 0) {
          _display = 'Error';
          _operand1 = '';
          _operator = '';
          return;
        } else {
          result = num1 / num2;
        }
        break;
      default:
        return;
    }

    // Remove unnecessary decimal if the result is an integer.
    if (result % 1 == 0) {
      _display = result.toInt().toString();
    } else {
      _display = result.toString();
    }
  }

  // Builds a rounded button that mimics the Apple Calculator style.
  Widget _buildButton(String text,
      {Color textColor = Colors.white,
      Color buttonColor = const Color(0xFF333333),
      int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        margin: EdgeInsets.all(6.0),
        child: Material(
          color: buttonColor,
          borderRadius: BorderRadius.circular(50.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(50.0),
            onTap: () => _onButtonPressed(text),
            child: Container(
              height: 70,
              alignment: Alignment.center,
              child: Text(
                text,
                style: TextStyle(fontSize: 28, color: textColor),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Display area showing current input/result.
            Container(
              padding: EdgeInsets.all(12),
              alignment: Alignment.centerRight,
              child: Text(
                _display,
                style: TextStyle(fontSize: 60, color: Colors.white),
              ),
            ),
            // History panel with a clear history button.
            Container(
              height: 120,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "History",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _history.clear();
                          });
                        },
                        child: Text(
                          "Clear History",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: _history.isEmpty
                        ? Center(
                            child: Text(
                              "No history",
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _history.length,
                            itemBuilder: (context, index) {
                              return Text(
                                _history[index],
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            // Calculator button grid.
            Expanded(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // First row: Clear (C) and division operator.
                    Row(
                      children: [
                        _buildButton('C',
                            textColor: Colors.black, buttonColor: Colors.grey),
                        // Placeholders to mimic layout.
                        _buildButton('', buttonColor: Colors.transparent),
                        _buildButton('', buttonColor: Colors.transparent),
                        _buildButton('÷',
                            textColor: Colors.orange,
                            buttonColor: Colors.grey[850]!),
                      ],
                    ),
                    // Second row: 7, 8, 9, multiplication operator.
                    Row(
                      children: [
                        _buildButton('7'),
                        _buildButton('8'),
                        _buildButton('9'),
                        _buildButton('×',
                            textColor: Colors.orange,
                            buttonColor: Colors.grey[850]!),
                      ],
                    ),
                    // Third row: 4, 5, 6, subtraction operator.
                    Row(
                      children: [
                        _buildButton('4'),
                        _buildButton('5'),
                        _buildButton('6'),
                        _buildButton('-',
                            textColor: Colors.orange,
                            buttonColor: Colors.grey[850]!),
                      ],
                    ),
                    // Fourth row: 1, 2, 3, addition operator.
                    Row(
                      children: [
                        _buildButton('1'),
                        _buildButton('2'),
                        _buildButton('3'),
                        _buildButton('+',
                            textColor: Colors.orange,
                            buttonColor: Colors.grey[850]!),
                      ],
                    ),
                    // Fifth row: 0, decimal point, equals.
                    Row(
                      children: [
                        // Make the 0 button wider.
                        _buildButton('0', flex: 2),
                        _buildButton('.'),
                        _buildButton('=',
                            textColor: Colors.white,
                            buttonColor: Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
