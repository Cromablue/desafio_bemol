import 'package:flutter_test/flutter_test.dart';
import 'package:desafio_bemol/models/exchange_rates.dart';

void main() {
  group('ExchangeRates Model Test', () {
    // Mock que simula a resposta da API, com ambos os formatos de data
    final Map<String, dynamic> mockJson = {
      "result": "success",
      "time_last_update_unix": 1672531201,
      "time_last_update_utc": "Sun, 01 Jan 2023 00:00:01 +0000",
      "base_code": "USD",
      "conversion_rates": {
        "USD": 1,
        "EUR": 0.9344,
        "BRL": 5.28,
        "JPY": 131.13,
      }
    };

    test('fromJson deve criar uma instância válida a partir de um JSON', () {
      // Ação
      final exchangeRates = ExchangeRates.fromJson(mockJson);

      // Verificação
      expect(exchangeRates.result, 'success');
      expect(exchangeRates.baseCode, 'USD');
      // CORREÇÃO: O teste agora verifica o timestamp numérico (int)
      expect(exchangeRates.timeLastUpdate, 1672531201); 
      expect(exchangeRates.conversionRates, isA<Map<String, double>>());
      expect(exchangeRates.conversionRates['BRL'], 5.28);
    });

    test('fromJson deve lidar com valores inteiros nas cotações', () {
      final jsonWithIntRate = {
        ...mockJson,
        "conversion_rates": { "USD": 1 }
      };
      
      // Ação
      final exchangeRates = ExchangeRates.fromJson(jsonWithIntRate);

      // Verificação
      expect(exchangeRates.conversionRates['USD'], 1.0);
      expect(exchangeRates.conversionRates['USD'], isA<double>());
    });

    // NOVO: Teste para o método toJson
    test('toJson deve converter a instância para um mapa JSON válido', () {
      // Preparação
      final exchangeRates = ExchangeRates.fromJson(mockJson);
      
      // Ação
      final jsonMap = exchangeRates.toJson();

      // Verificação
      expect(jsonMap['result'], 'success');
      expect(jsonMap['base_code'], 'USD');
      // Garante que a chave correta do timestamp está sendo usada
      expect(jsonMap['time_last_update_unix'], 1672531201); 
      expect(jsonMap['conversion_rates']['EUR'], 0.9344);
    });
  });
}