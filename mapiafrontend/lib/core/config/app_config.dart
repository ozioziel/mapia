
import 'package:flutter/foundation.dart';

class AppConfig {
  static String get apiBaseUrl {
    const env = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (env.isNotEmpty) {
      return env;
    }

    // IP de tu computadora en la red Wi-Fi
    // Esto asegura que funcione perfectamente en Emulador, Web y Dispositivo físico sin fallos.
    return 'http://192.168.1.204:3000/api/v1';
  }

  static const googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );
}
