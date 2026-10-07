// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NEST Worker';

  @override
  String get foundationHeadline => 'Setup complete';

  @override
  String get foundationBody =>
      'Tasks, work timer and photos will appear here in the next releases.';
}
