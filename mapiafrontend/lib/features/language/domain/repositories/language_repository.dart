import 'package:flutter/widgets.dart';

abstract class LanguageRepository {
  Future<Locale?> readLocale();
  Future<void> saveLocale(Locale locale);
}
