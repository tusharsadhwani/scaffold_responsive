import 'package:flutter/material.dart';

import 'package:scaffold_responsive/scaffold_responsive.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final title = 'Responsive Scaffold Demo';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
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
  final menuController = ResponsiveMenuController();

  void setTab(String newTab) {
    setState(() {
      tab = newTab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      menu: _buildMenu(),
      menuController: menuController,
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: menuController.toggle,
      ),
      title: Text(MyApp.title),
    );
  }

  Center _buildBody() {
    const _textStyle = TextStyle(color: Colors.black, fontSize: 26.0);
    return Center(
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
    );
  }

  Widget _buildMenu() => Drawer(
        backgroundColor: Colors.grey.shade300,
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            ListTile(
              title: const Text('Close the Menu'),
              onTap: () {
                menuController.close();
              },
            ),
            for (int i = 1; i < 5; i++)
              ListTile(
                title: Text('Page $i'),
                onTap: () async {
                  setTab('Page $i');
                  menuController.closeIfNeeded();
                },
              ),
          ],
        ),
      );
}
