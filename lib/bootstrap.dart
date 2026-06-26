import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:genui/genui.dart';

import 'package:hob_it/firebase_options.dart';
import 'package:logging/logging.dart';

/// Initializes Firebase and runs the Flutter app built by [builder].
Future<void> bootstrap(Widget Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();

  final logger = configureLogging(level: Level.ALL);
  logger.onRecord.listen((record) {
    debugPrint('[${record.loggerName}] ${record.message}');
  });

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(builder());
}
