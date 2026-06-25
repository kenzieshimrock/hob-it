import 'package:flutter/material.dart';
import 'package:hob_it/features/discovery/view/discovery_page.dart';

/// {@template app}
/// The root widget of the hob-it application.
/// {@endtemplate}
class App extends StatelessWidget {
  /// {@macro app}
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'hob-it',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2A48DE)),
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: const DiscoveryPage(),
    );
  }
}
