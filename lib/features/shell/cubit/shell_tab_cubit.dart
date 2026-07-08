import 'package:bloc/bloc.dart';

/// Holds the selected bottom-navigation tab for the shell.
///
/// App-scoped so any tab can switch the shell, e.g. Home or Hobbies opening
/// the Discover tab.
class ShellTabCubit extends Cubit<int> {
  /// Creates a [ShellTabCubit] starting on Home.
  ShellTabCubit() : super(homeTab);

  /// Home tab index.
  static const int homeTab = 0;

  /// Discover tab index.
  static const int discoverTab = 1;

  /// Hobbies tab index.
  static const int hobbiesTab = 2;

  /// Settings tab index.
  static const int settingsTab = 3;

  /// Selects the tab at [index].
  void select(int index) => emit(index);

  /// Switches to the Discover tab.
  void openDiscover() => emit(discoverTab);
}
