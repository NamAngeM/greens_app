enum Environment {
  development,
  staging,
  production
}

class EnvironmentConfig {
  final String apiUrl;
  final String apiKey;

  EnvironmentConfig({
    required this.apiUrl,
    required this.apiKey,
  });

  static EnvironmentConfig getConfig(Environment env) {
    switch (env) {
      case Environment.development:
        return EnvironmentConfig(
          apiUrl: 'https://dev-api.example.com',
          apiKey: 'dev-key'
        );
      case Environment.staging:
        return EnvironmentConfig(
          apiUrl: 'https://staging-api.example.com',
          apiKey: 'staging-key'
        );
      case Environment.production:
        return EnvironmentConfig(
          apiUrl: 'https://api.example.com',
          apiKey: 'prod-key'
        );
    }
  }
}