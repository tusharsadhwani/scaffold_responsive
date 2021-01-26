# scaffold_responsive

A responsive scaffold widget that adjusts to your device size, for your flutter mobile and web apps.

![Demo](https://user-images.githubusercontent.com/43412083/86610702-8f4b5300-bf62-11ea-8a83-dac608c910c5.gif)

[Check out the Live demo here](https://tusharsadhwani.github.io/scaffold_responsive)

## Usage

```dart
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
    return ResponsiveScaffold(
      title: Text('Responsive Scaffold Demo'),
      body: Center(
        child: Text('Selected tab: $tab'),
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
```
