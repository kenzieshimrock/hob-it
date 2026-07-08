import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hob_it/features/features.dart';
import 'package:hob_it/ui/ui.dart';
import 'package:hobby_repository/hobby_repository.dart';
import 'package:in_memory_hobby_api/in_memory_hobby_api.dart';

/// Root widget of the hob-it application.
class App extends StatelessWidget {
  /// Creates an [App].
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => HobbyRepository(hobbyApi: InMemoryHobbyApi()),
      child: MaterialApp(
        title: 'hob-it',
        debugShowCheckedModeBanner: false,
        theme: HobItTheme.light,
        home: const ShellPage(),
      ),
    );
  }
}
