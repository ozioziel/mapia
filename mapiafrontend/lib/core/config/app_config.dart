class AppConfig {
  static const productionApiBaseUrl = 'http://144.22.43.169:3001/api/v1';

  static String get apiBaseUrl {
    const env = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (env.isNotEmpty) {
      return _normalizeApiBaseUrl(env);
    }

    return productionApiBaseUrl;
  }

  static const googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  static String _normalizeApiBaseUrl(String value) {
    return value.trim().replaceFirst(RegExp(r'/+$'), '');
  }
}
