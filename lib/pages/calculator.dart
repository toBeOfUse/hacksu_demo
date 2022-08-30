import 'dart:developer';

import "package:expressions/expressions.dart";
import 'package:flutter/material.dart';

class Calculator extends StatefulWidget {
  const Calculator({Key? key}) : super(key: key);

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  static const buttonRows = [
    ["7", "8", "9", "*"],
    ["4", "5", "6", "/"],
    ["1", "2", "3", "-"],
    ["0", ".", "<", "+"]
  ];

  String currentEquation = "";

  void processButtonPress(String buttonLabel) {
    setState(() {
      if (buttonLabel == "<" && currentEquation.isNotEmpty) {
        currentEquation =
            currentEquation.substring(0, currentEquation.length - 1);
      } else if (buttonLabel == "CE") {
        currentEquation = "";
      } else {
        currentEquation += buttonLabel;
      }
    });
  }

  void performEquals() {
    try {
      final parsedResult = Expression.parse(currentEquation);
      final evaluatedResult = ExpressionEvaluator().eval(parsedResult, {});
      final stringResult = evaluatedResult.toString();
      setState(() {
        currentEquation = stringResult;
      });
    } catch (e) {
      log("could evaluate expression $currentEquation");
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 200,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.all(3.0),
                child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54),
                        borderRadius: BorderRadius.circular(3)),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Text(currentEquation, textAlign: TextAlign.end),
                    )),
              ),
              ElevatedButton(
                  onPressed: () => processButtonPress("CE"), child: Text("CE")),
              Table(children: [
                for (final buttons in buttonRows)
                  TableRow(children: [
                    for (final button in buttons)
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: OutlinedButton(
                            child: button == "<"
                                ? Icon(Icons.backspace)
                                : Text(button),
                            onPressed: () => processButtonPress(button)),
                      ),
                  ])
              ]),
              ElevatedButton(onPressed: performEquals, child: Text("="))
            ]),
      ),
    );
  }
}
