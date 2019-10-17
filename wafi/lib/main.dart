import 'package:flutter/material.dart';
import 'package:wafi/pages/root_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wafi',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
      ),
      home: Scaffold(
        body: RootPage(),
        ),
    );
  }
}