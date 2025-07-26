class CurrencyData {
  // Nomes e símbolos em português para as moedas mais comuns
  static const Map<String, Map<String, String>> _info = {
    'USD': {'name': 'Dólar Americano', 'symbol': '\$'},
    'EUR': {'name': 'Euro', 'symbol': '€'},
    'JPY': {'name': 'Iene Japonês', 'symbol': '¥'},
    'GBP': {'name': 'Libra Esterlina', 'symbol': '£'},
    'BRL': {'name': 'Real Brasileiro', 'symbol': 'R\$'},
    'AUD': {'name': 'Dólar Australiano', 'symbol': 'A\$'},
    'CAD': {'name': 'Dólar Canadense', 'symbol': 'C\$'},
    'CHF': {'name': 'Franco Suíço', 'symbol': 'CHF'},
    'CNY': {'name': 'Yuan Chinês', 'symbol': '¥'},
    'ARS': {'name': 'Peso Argentino', 'symbol': '\$'},
    'CLP': {'name': 'Peso Chileno', 'symbol': '\$'},
    'MXN': {'name': 'Peso Mexicano', 'symbol': '\$'},
    'COP': {'name': 'Peso Colombiano', 'symbol': '\$'},
  };

  // Moedas com alta volatilidade
  static const Set<String> volatileCurrencies = {
    'ARS', 'LYD', 'SSP', 'SYP', 'VES', 'YER', 'ZWL'
  };

  /// Retorna o nome completo e localizado de uma moeda, se disponível.
  static String getFullName(String code, String defaultName) {
    return _info[code]?['name'] ?? defaultName;
  }

  /// Retorna o símbolo de uma moeda.
  static String getCurrencySymbol(String code) {
    return _info[code]?['symbol'] ?? code;
  }

  /// Remove acentos de uma string para facilitar buscas.
  static String normalize(String input) {
    const from = 'ÀÁÂÃÄÅàáâãäåÇçÈÉÊËèéêëÌÍÎÏìíîïÑñÒÓÔÕÖØòóôõöøÙÚÛÜùúûü';
    const to   = 'AAAAAAaaaaaaCcEEEEeeeeIIIIiiiiNnOOOOOOooooooUUUUuuuu';
    String result = input;
    for (int i = 0; i < from.length; i++) {
      result = result.replaceAll(from[i], to[i]);
    }
    return result;
  }
}