
import 'package:flutter/foundation.dart';

class AppConfig {
  static String get apiBaseUrl {
    const env = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (env.isNotEmpty) {
      return env;
    }

    // En Flutter Web (Chrome/Edge) la app corre en el mismo host → usar localhost.
    // En emulador Android o dispositivo físico usar la IP de la red local.
    if (kIsWeb) {
      return 'http://localhost:3000/api/v1';
    }

    // IP de tu computadora en la red Wi-Fi (para emulador/dispositivo físico)
    return 'http://192.168.1.204:3000/api/v1';
  }

  static const googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );
}
