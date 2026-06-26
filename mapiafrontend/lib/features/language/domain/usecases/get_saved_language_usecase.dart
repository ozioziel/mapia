import 'package:flutter/widgets.dart';
import 'package:mapiafrontend/features/language/domain/repositories/language_repository.dart';

class GetSavedLanguageUseCase {
  const GetSavedLanguageUseCase(this.repository);

  final LanguageRepository repository;

  Future<Locale?> call() => repository.readLocale();
}
