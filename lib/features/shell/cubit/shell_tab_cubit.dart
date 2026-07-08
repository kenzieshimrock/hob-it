import 'package:bloc/bloc.dart';

/// The bottom-navigation tabs of the shell.
enum ShellTab {
  /// Home Tab
  home,

  /// Discover Tab
  discover,

  /// Hobbies Tab
  hobbies,

  /// Settings Tab
  settings,
}

/// Holds the selected shell tab so any tab can switch the shell, e.g. Home or
/// Hobbies opening the Discover tab.
class ShellTabCubit extends Cubit<ShellTab> {
  /// Creates a [ShellTabCubit] starting on Home.
  ShellTabCubit() : super(ShellTab.home);

  /// Selects [tab].
  void select(ShellTab tab) => emit(tab);

  /// Switches to the Discover tab.
  void openDiscover() => emit(ShellTab.discover);
}
