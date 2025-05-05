/// Classe utilitaire pour gérer la configuration des modèles de langage
class LlmConfig {
  /// Récupérer l'URL de l'API
  static Future<String> getApiUrl() async {
    // Retourner l'URL par défaut pour n8n
    return 'https://angenam.app.n8n.cloud/webhook-test/chatbot-eco';
  }

  /// Sauvegarder l'URL de l'API
  static Future<void> saveApiUrl(String url) async {
    // Cette méthode est un placeholder puisque nous utilisons maintenant n8n
    // et n'avons plus besoin de sauvegarder l'URL
  }

  /// Vérifier si l'URL de l'API est valide
  static bool isValidApiUrl(String url) {
    // Vérifier si l'URL est valide
    return url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://'));
  }
}