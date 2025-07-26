import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/exchange_rates.dart';
import '../models/pair_conversion.dart';
import '../models/supported_codes.dart';

class CurrencyService {
  static String get _apiKey => dotenv.env['EXCHANGE_RATE_API_KEY'] ?? '';
  static const String _baseUrl = 'https://v6.exchangerate-api.com/v6';
  static final Map<String, dynamic> _cache = {};
  static DateTime? _lastFetchTime;

  /// Busca as cotações mais recentes usando um cache local para evitar chamadas repetidas
  static Future<ExchangeRates> getExchangeRatesWithCache({
    String baseCurrency = 'USD',
    Duration cacheDuration = const Duration(minutes: 10),
  }) async {
    final cacheKey = 'rates_$baseCurrency';
    final now = DateTime.now();

    // Se houver dados válidos no cache retorna-os imediatamente
    if (_cache.containsKey(cacheKey) &&
        _lastFetchTime != null &&
        now.difference(_lastFetchTime!).compareTo(cacheDuration) < 0) {
      return ExchangeRates.fromJson(_cache[cacheKey]);
    }

    // Se não, busca novos dados na API
    final rates = await getExchangeRates(baseCurrency: baseCurrency);
    _cache[cacheKey] = rates.toJson(); // Salva os novos dados no cache
    _lastFetchTime = now;
    return rates;
  }

  /// procura as cotações mais recentes diretamente da API
  static Future<ExchangeRates> getExchangeRates({String baseCurrency = 'USD'}) async {
    if (_apiKey.isEmpty) throw Exception('API Key não configurada');
    final url = '$_baseUrl/$_apiKey/latest/$baseCurrency';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['result'] == 'success') return ExchangeRates.fromJson(json);
        throw Exception('Erro da API: ${json['error-type']}');
      }
      throw Exception('Erro HTTP: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
  
  /// Converte um valor entre um par de moedas específico
  static Future<PairConversion> convertCurrency({
    required String from,
    required String to,
    double amount = 1.0,
  }) async {
    if (_apiKey.isEmpty) throw Exception('API Key não configurada');
    final url = '$_baseUrl/$_apiKey/pair/$from/$to/$amount';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['result'] == 'success') return PairConversion.fromJson(json);
        throw Exception('Erro da API: ${json['error-type']}');
      }
      throw Exception('Falha na conversão: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erro de conversão: $e');
    }
  }
  
  /// Puxa a lista de todas as moedas suportadas pela API
  static Future<List<SupportedCode>> getSupportedCodes() async {
    if (_apiKey.isEmpty) throw Exception('API Key não configurada');
    final url = '$_baseUrl/$_apiKey/codes';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['result'] == 'success') {
          final codesList = json['supported_codes'] as List;
          return codesList.map((item) => SupportedCode.fromList(item)).toList();
        }
        throw Exception('Erro da API: ${json['error-type']}');
      }
      throw Exception('Falha ao obter códigos: ${response.statusCode}');
    } catch (e) {
      throw Exception('Erro ao obter códigos: $e');
    }
  }
}