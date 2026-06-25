import 'package:flutter/material.dart';
import 'package:hob_it/features/shell/view/shell_page.dart';
import 'package:hob_it/ui/ui.dart';

/// Root widget of the hob-it application.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'hob-it',
      debugShowCheckedModeBanner: false,
      theme: HobItTheme.light,
      home: const ShellPage(),
    );
  }
}
