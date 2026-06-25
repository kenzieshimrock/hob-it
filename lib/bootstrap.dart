import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

import 'package:hob_it/firebase_options.dart';

/// Initializes Firebase and runs the Flutter app built by [builder].
Future<void> bootstrap(Widget Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(builder());
}
