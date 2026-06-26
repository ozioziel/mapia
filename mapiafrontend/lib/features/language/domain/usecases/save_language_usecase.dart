import 'package:flutter/widgets.dart';
import 'package:mapiafrontend/features/language/domain/repositories/language_repository.dart';

class SaveLanguageUseCase {
  const SaveLanguageUseCase(this.repository);

  final LanguageRepository repository;

  Future<void> call(Locale locale) => repository.saveLocale(locale);
}
