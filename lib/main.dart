import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math';

void main() {
  runApp(const SimpleCalcApp());
}

class SimpleCalcApp extends StatelessWidget {
  const SimpleCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SimpleCalc',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CalculatorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String displayText = '';
  String expression = '';
  bool shouldResetDisplay = false;
  bool isNextNegative = false;
  List<String> history = []; // To store the last 10 calculations

  final int maxDigits = 15;

  void evaluateExpression() {
    try {
      String processedExpression = expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('%', '*0.01');

      Parser parser = Parser();
      Expression exp = parser.parse(processedExpression);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);

      setState(() {
        displayText = result
            .toStringAsFixed(8)
            .replaceAll(RegExp(r"0*$"), "")
            .replaceAll(RegExp(r"\.$"), "");

        // Add to history
        if (history.length == 10) {
          history.removeAt(0); // Remove the oldest calculation
        }
        history.add("$expression = $displayText");
      });
    } catch (e) {
      setState(() {
        displayText = "Error";
      });
    }
  }

  void showHistory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("History"),
          content: SizedBox(
            height: 300, // Constrain the height of the history dialog
            width: MediaQuery.of(context).size.width * 0.8,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: history.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(history[history.length - 1 - index]),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        displayText = '';
        expression = '';
        shouldResetDisplay = false;
        isNextNegative = false;
      } else if (buttonText == "=") {
        if (expression.isNotEmpty) {
          evaluateExpression();
        }
      } else if (["+", "-", "*", "/", "%"].contains(buttonText)) {
        if (expression.isEmpty && buttonText != "-") return;
        if (RegExp(r"[+\-*/%]$").hasMatch(expression)) return;
        expression += " $buttonText";
        shouldResetDisplay = true;
        isNextNegative = false;
      } else if (buttonText == "⌫") {
        if (displayText.isNotEmpty) {
          displayText = displayText.substring(0, displayText.length - 1);
        }
        if (expression.isNotEmpty) {
          expression = expression.substring(0, expression.length - 1);
        }
      } else if (buttonText == "+/-") {
        if (shouldResetDisplay) {
          isNextNegative = !isNextNegative;
          expression += isNextNegative ? "-" : "";
        } else if (displayText.isNotEmpty) {
          double number = double.tryParse(displayText) ?? 0;
          displayText = (number * -1)
              .toStringAsFixed(8)
              .replaceAll(RegExp(r"0*$"), "")
              .replaceAll(RegExp(r"\.$"), "");

          if (expression.isEmpty || expression.endsWith("=")) {
            expression = displayText;
          } else {
            RegExp regex = RegExp(r"[-]?\d+(\.\d+)?$");
            expression = expression.replaceFirst(regex, displayText);
          }
        }
      } else if (buttonText == "√") {
        double number = double.tryParse(displayText) ?? 0;
        if (number >= 0) {
          double result = sqrt(number);
          displayText = result
              .toStringAsFixed(8)
              .replaceAll(RegExp(r"0*$"), "")
              .replaceAll(RegExp(r"\.$"), "");
          expression = "√($expression)";
        } else {
          displayText = "Error";
        }
      } else {
        if (shouldResetDisplay) {
          displayText = isNextNegative ? "-$buttonText" : buttonText;
          shouldResetDisplay = false;
          isNextNegative = false;
        } else if (displayText.length < maxDigits) {
          displayText = displayText.isEmpty
              ? (isNextNegative ? "-$buttonText" : buttonText)
              : displayText + buttonText;
          isNextNegative = false;
        }

        expression += buttonText;
      }
    });
  }

  Widget buildButton(String buttonText,
      {Color? textColor, Color? backgroundColor}) {
    textColor ??= Colors.black;
    backgroundColor ??= Colors.white;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(1, 1),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => buttonPressed(buttonText),
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
          ),
          child: Text(
            buttonText,
            style: TextStyle(
              fontSize: 24,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    expression,
                    style: const TextStyle(color: Colors.grey, fontSize: 24),
                  ),
                  FittedBox(
                    child: Text(
                      displayText.isEmpty ? "0" : displayText,
                      style: const TextStyle(color: Colors.black, fontSize: 48),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: showHistory,
                    child: const Text(
                      "History",
                      style: TextStyle(fontSize: 18, color: Colors.orange),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => buttonPressed("⌫"),
                    child: const Text(
                      "⌫",
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Colors.grey,
              thickness: 1,
              height: 20,
            ),
            Column(
              children: [
                Row(
                  children: [
                    buildButton("C", textColor: Colors.red),
                    buildButton("√",
                        backgroundColor: Colors.white, textColor: Colors.blue),
                    buildButton("%", textColor: Colors.blue),
                    buildButton("/", textColor: Colors.blue),
                  ],
                ),
                Row(
                  children: [
                    buildButton("7"),
                    buildButton("8"),
                    buildButton("9"),
                    buildButton("*", textColor: Colors.blue),
                  ],
                ),
                Row(
                  children: [
                    buildButton("4"),
                    buildButton("5"),
                    buildButton("6"),
                    buildButton("-", textColor: Colors.blue),
                  ],
                ),
                Row(
                  children: [
                    buildButton("1"),
                    buildButton("2"),
                    buildButton("3"),
                    buildButton("+", textColor: Colors.blue),
                  ],
                ),
                Row(
                  children: [
                    buildButton("+/-"),
                    buildButton("0"),
                    buildButton("."),
                    buildButton("=",
                        backgroundColor: Colors.green, textColor: Colors.white),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
