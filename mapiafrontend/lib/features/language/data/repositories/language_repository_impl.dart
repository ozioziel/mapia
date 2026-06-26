import 'package:flutter/widgets.dart';
import 'package:mapiafrontend/features/language/data/datasources/language_local_datasource.dart';
import 'package:mapiafrontend/features/language/domain/repositories/language_repository.dart';

class LanguageRepositoryImpl implements LanguageRepository {
  const LanguageRepositoryImpl({
    this.datasource = const LanguageLocalDatasource(),
  });

  final LanguageLocalDatasource datasource;

  @override
  Future<Locale?> readLocale() => datasource.readLocale();

  @override
  Future<void> saveLocale(Locale locale) => datasource.saveLocale(locale);
}
