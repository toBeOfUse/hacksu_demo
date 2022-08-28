import 'package:flutter/material.dart';

class HelloWorld extends StatelessWidget {
  const HelloWorld({Key? key}) : super(key: key);
  static const name = "Hello World";

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Hello World"));
  }
}
