// services/currency_service.dart
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../models/exchange_rates.dart';

class CurrencyService {
  static String get _apiKey => dotenv.env['EXCHANGE_RATE_API_KEY'] ?? '';
  static const String _baseUrl = 'https://v6.exchangerate-api.com/v6';

  static Future<ExchangeRates> getExchangeRates({String baseCurrency = 'USD'}) async {
    if (_apiKey.isEmpty) {
      throw Exception('API Key não configurada');
    }
    
    final url = '$_baseUrl/$_apiKey/latest/$baseCurrency';
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ExchangeRates.fromJson(json);
      } else {
        throw Exception('Falha ao carregar cotações: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}