// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'NEST Worker';

  @override
  String get foundationHeadline => 'Настройка завершена';

  @override
  String get foundationBody =>
      'Задачи, таймер работы и фотографии появятся здесь в следующих версиях.';
}
