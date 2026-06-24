import 'package:flutter/material.dart';

class App extends StatelessWidget {
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
      home: const Scaffold(body: Center(child: Text('hob-it'))),
    );
  }
}
