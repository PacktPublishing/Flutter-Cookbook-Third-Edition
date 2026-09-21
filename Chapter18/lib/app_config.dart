class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const apiKey = String.fromEnvironment(
    'API_KEY',
  );

  static const showDebugBanner = bool.fromEnvironment(
    'SHOW_DEBUG_BANNER',
  );

  static const logLevel = String.fromEnvironment(
    'LOG_LEVEL',
    defaultValue: 'info',
  );
}
