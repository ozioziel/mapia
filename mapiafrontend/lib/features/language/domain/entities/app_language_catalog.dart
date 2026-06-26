import 'package:flutter/widgets.dart';
import 'package:mapiafrontend/features/language/domain/entities/app_language_entity.dart';

class AppLanguageCatalog {
  const AppLanguageCatalog._();

  static const primaryLanguages = [
    AppLanguageEntity(
      name: 'Castellano',
      nativeName: 'Español',
      locale: Locale('es'),
      status: AppLanguageStatus.available,
    ),
    AppLanguageEntity(
      name: 'Quechua',
      locale: Locale('qu'),
      status: AppLanguageStatus.partial,
    ),
    AppLanguageEntity(
      name: 'Aymara',
      locale: Locale('ay'),
      status: AppLanguageStatus.partial,
    ),
    AppLanguageEntity(
      name: 'Guaraní',
      locale: Locale('gn'),
      status: AppLanguageStatus.partial,
    ),
  ];

  static const otherOfficialLanguages = [
    'Araona',
    'Baure',
    'Bésiro / Chiquitano',
    'Canichana',
    'Cavineño',
    'Cayubaba',
    'Chácobo',
    'Chimán / Tsimané',
    'Ese Ejja',
    "Guarasu'we",
    'Guarayu',
    'Itonama',
    'Leco',
    'Machajuyai-kallawaya',
    'Machineri',
    'Maropa',
    'Mojeño-trinitario',
    'Mojeño-ignaciano',
    'Moré',
    'Mosetén',
    'Movima',
    'Pacawara',
    'Puquina',
    'Sirionó',
    'Tacana',
    'Tapiete',
    'Toromona',
    'Uru-chipaya',
    'Weenhayek',
    'Yaminawa',
    'Yuki',
    'Yuracaré',
    'Zamuco / Ayoreo',
  ];
}
