import 'package:flutter/material.dart';

import 'package:scaffold_responsive/scaffold_responsive.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Responsive Scaffold Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String tab;

  void setTab(String newTab) {
    setState(() {
      tab = newTab;
    });
  }

  @override
  Widget build(BuildContext context) {
    const _textStyle = TextStyle(color: Colors.black, fontSize: 26.0);
    return ResponsiveScaffold(
      title: Text('Responsive Scaffold Demo'),
      body: Center(
        child: RichText(
          text: TextSpan(
            text: 'Selected tab: ',
            style: _textStyle,
            children: [
              TextSpan(
                text: tab,
                style: _textStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      tabs: [
        {
          'title': 'Chapter A',
          'children': [
            {'title': 'Chapter A1'},
            {'title': 'Chapter A2'},
          ],
        },
        {
          'title': 'Chapter B',
          'children': [
            {'title': 'Chapter B1'},
            {
              'title': 'Chapter B2',
              'children': [
                {'title': 'Chapter B2a'},
                {'title': 'Chapter B2b'},
              ],
            },
          ],
        },
        {
          'title': 'Chapter C',
        },
      ],
      onTabChanged: setTab,
    );
  }
}
