import 'package:flutter/widgets.dart';

enum AppLanguageStatus { available, partial, preparing }

class AppLanguageEntity {
  const AppLanguageEntity({
    required this.name,
    required this.locale,
    required this.status,
    this.nativeName,
  });

  final String name;
  final String? nativeName;
  final Locale locale;
  final AppLanguageStatus status;

  bool get canSelect => status != AppLanguageStatus.preparing;
}
