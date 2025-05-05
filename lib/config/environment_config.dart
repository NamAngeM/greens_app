enum Environment {
  development,
  staging,
  production
}

class EnvironmentConfig {
  final String apiUrl;
  final bool enableLogging;

  EnvironmentConfig({
    required this.apiUrl,
    required this.enableLogging,
  });

  static EnvironmentConfig getConfig(Environment env) {
    switch (env) {
      case Environment.development:
        return EnvironmentConfig(
          apiUrl: 'http://localhost:8080',
          enableLogging: true,
        );
      case Environment.staging:
        return EnvironmentConfig(
          apiUrl: 'https://staging-api.example.com',
          enableLogging: true,
        );
      case Environment.production:
        return EnvironmentConfig(
          apiUrl: 'https://api.example.com',
          enableLogging: false,
        );
    }
  }
}