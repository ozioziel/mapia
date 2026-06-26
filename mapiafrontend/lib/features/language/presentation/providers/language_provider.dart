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

  // Flutter's Material/Cupertino localization delegates do not support every
  // language Mapia wants to prepare. Keep the user's Mapia language selection,
  // but use Spanish for Flutter framework strings until those locales have
  // supported framework delegates or validated translations.
  Locale get frameworkLocale {
    return switch (_locale.languageCode) {
      'es' => _locale,
      _ => const Locale('es'),
    };
  }

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
