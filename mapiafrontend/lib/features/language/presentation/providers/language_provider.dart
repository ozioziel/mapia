import 'package:flutter/widgets.dart';
import 'package:mapiafrontend/features/language/data/repositories/language_repository_impl.dart';
import 'package:mapiafrontend/features/language/domain/usecases/get_saved_language_usecase.dart';
import 'package:mapiafrontend/features/language/domain/usecases/save_language_usecase.dart';

class LanguageProvider extends ChangeNotifier {
  LanguageProvider({
    GetSavedLanguageUseCase? getSavedLanguage,
    SaveLanguageUseCase? saveLanguage,
  }) : _getSavedLanguage =
           getSavedLanguage ??
           const GetSavedLanguageUseCase(LanguageRepositoryImpl()),
       _saveLanguage =
           saveLanguage ?? const SaveLanguageUseCase(LanguageRepositoryImpl());

  final GetSavedLanguageUseCase _getSavedLanguage;
  final SaveLanguageUseCase _saveLanguage;

  Locale _locale = const Locale('es');
  Locale get locale => _locale;

  Future<void> load() async {
    final saved = await _getSavedLanguage();
    if (saved == null) return;
    _locale = saved;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    await _saveLanguage(locale);
  }
}
