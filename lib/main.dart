// ignore_for_file: prefer_const_constructors

import 'package:blog/screens/loading.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blog app',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const Loading(),
    );
  }
}
