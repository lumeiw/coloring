import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pdfrx/pdfrx.dart';

import 'app/coloring_app.dart';
import 'core/di/injection.dart';

/// Точка сборки приложения: инициализация DI, pdfium и запуск виджета.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await pdfrxFlutterInitialize();
  await configureDependencies();
  runApp(const ColoringApp());
}
