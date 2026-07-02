import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

/// Инициализация DI-контейнера. Вызывается один раз при старте (см. bootstrap).
@InjectableInit()
Future<void> configureDependencies() => getIt.init();
