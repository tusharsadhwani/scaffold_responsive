import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:scaffold_responsive/scaffold_responsive.dart';

void main() {
  test('adds one to input values', () {
    final menuController=ResponsiveMenuController();
    final scaffold = ResponsiveScaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: menuController.toggle,
          ),
          title: const Text('Test')),
      menu: const Text('My Custom Menu'),
      menuController: menuController,
      body: Container(),
    );
    expect(scaffold.runtimeType, ResponsiveScaffold);
  });
}
