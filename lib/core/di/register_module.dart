import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Регистрация внешних зависимостей, которые нельзя пометить аннотацией
/// напрямую (создаются асинхронно или живут в сторонних пакетах).
@module
abstract class RegisterModule {
  /// Настройки приложения (тема, последние параметры кисти и т.п.).
  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();
}
