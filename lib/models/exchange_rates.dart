class ExchangeRates {
  final String result;
  final String baseCode;
  final int timeLastUpdate;
  final Map<String, double> conversionRates;

  ExchangeRates({
    required this.result,
    required this.baseCode,
    required this.timeLastUpdate,
    required this.conversionRates,
  });

  factory ExchangeRates.fromJson(Map<String, dynamic> json) {
    return ExchangeRates(
      result: json['result'],
      baseCode: json['base_code'],
      timeLastUpdate: json['time_last_update_unix'], 
      conversionRates: Map<String, double>.from(
        json['conversion_rates'].map((key, value) => MapEntry(key, (value as num).toDouble())),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result': result,
      'base_code': baseCode,
      'time_last_update_unix': timeLastUpdate,
      'conversion_rates': conversionRates,
    };
  }
}