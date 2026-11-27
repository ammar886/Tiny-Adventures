import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tiny_adventures/app/app.dart';
import 'package:tiny_adventures/app/app_dependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final dependencies = AppDependencies.createDefault();
  await dependencies.initialize();

  runApp(TinyAdventuresApp(dependencies: dependencies));
}
