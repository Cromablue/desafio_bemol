class ErrorHandler {
  /// Converte um erro técnico em uma mensagem amigável para o usuário.
  static String getFriendlyError(dynamic error) {
    String errorMessage = error.toString().toLowerCase();

    if (errorMessage.contains('socketexception') || errorMessage.contains('failed host lookup')) {
      return 'Erro de conexão. Verifique sua internet e tente novamente.';
    }
    if (errorMessage.contains('api key')) {
      return 'Erro de autenticação com o serviço. Contate o suporte.';
    }
    if (errorMessage.contains('http')) {
      return 'Não foi possível comunicar com o servidor. Tente mais tarde.';
    }
    
    return 'Ocorreu um erro inesperado. Por favor, tente novamente.';
  }
}