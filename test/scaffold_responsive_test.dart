import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:scaffold_responsive/scaffold_responsive.dart';

void main() {
  test('adds one to input values', () {
    final scaffold = ResponsiveScaffold(
      title: Text('Test'),
      body: Container(),
      tabs: [],
    );
    expect(scaffold.runtimeType, ResponsiveScaffold);
  });
}
