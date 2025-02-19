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
        // Clear current input.
        _display = '0';
        _operand1 = '';
        _operator = '';
      } else if (value == '⌫') {
        // Backspace: remove the last character.
        if (_display == 'Error') {
          _display = '0';
        } else if (_display.length > 1) {
          _display = _display.substring(0, _display.length - 1);
        } else {
          _display = '0';
        }
      } else if (value == '+' || value == '-' || value == '×' || value == '÷') {
        // Set operator or perform chained calculation.
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
        // Execute calculation if possible.
        if (_operator.isNotEmpty && _operand1.isNotEmpty) {
          String expression = "$_operand1 $_operator $_display";
          _calculate();
          // Save to history if there’s no error.
          if (_display != 'Error') {
            _history.add("$expression = $_display");
          }
          _operator = '';
        }
      } else {
        // Handle number or decimal point.
        if (_shouldResetDisplay || _display == '0') {
          _display = '';
          _shouldResetDisplay = false;
        }
        // Avoid multiple decimals.
        if (value == '.' && _display.contains('.')) return;
        _display += value;
      }
    });
  }

  // Performs arithmetic based on the stored operator.
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
    // If result is an integer, show without a decimal point.
    if (result % 1 == 0)
      _display = result.toInt().toString();
    else
      _display = result.toString();
  }

  // Helper to build a styled button.
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
            // Display for current input/result.
            Container(
              padding: EdgeInsets.all(12),
              alignment: Alignment.centerRight,
              child: Text(
                _display,
                style: TextStyle(fontSize: 60, color: Colors.white),
              ),
            ),
            // History panel with Apple-like styling.
            Container(
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              padding: EdgeInsets.all(8),
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  // Header with "History" title and clear button.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "History",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _history.clear();
                          });
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: Text(
                          "Clear",
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  // Display list of history entries.
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
            // Calculator keypad.
            Expanded(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // First row: Clear (C), Backspace (⌫), placeholder, Division (÷).
                    Row(
                      children: [
                        _buildButton('C',
                            textColor: Colors.black, buttonColor: Colors.grey),
                        _buildButton('⌫',
                            textColor: Colors.black, buttonColor: Colors.grey),
                        _buildButton('',
                            buttonColor: Colors.transparent), // Placeholder
                        _buildButton('÷',
                            textColor: Colors.orange,
                            buttonColor: Colors.grey[850]!),
                      ],
                    ),
                    // Second row: 7, 8, 9, Multiplication (×).
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
                    // Third row: 4, 5, 6, Subtraction (-).
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
                    // Fourth row: 1, 2, 3, Addition (+).
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
                    // Fifth row: 0 (double width), Decimal (.), Equals (=).
                    Row(
                      children: [
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
