import 'package:flutter/material.dart';
import 'package:hacksu_demo/pages/imperative.dart';

import "pages/helloworld.dart";
import "pages/calculator.dart";

final pageIndex = {
  "Hello World": () => HelloWorld(),
  "Calculator": () => Calculator(),
  "Imperative UI Simulator": () => CharacterScene()
};

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String currentPage = "Hello World";
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "HacKSU Demo",
      home: Scaffold(
        appBar: AppBar(title: Text("HacKSU Demo")),
        body: pageIndex[currentPage]!(),
        drawer: Drawer(
          child: ListView(
            children: [
              for (final page in pageIndex.keys)
                ListTile(
                    title: Text(page),
                    selected: page == currentPage,
                    onTap: () {
                      setState(() {
                        currentPage = page;
                      });
                    })
            ],
          ),
        ),
      ),
    );
  }
}
