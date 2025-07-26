class PairConversion {
  final String result;
  final String baseCode;
  final String targetCode;
  final double conversionRate;
  final double conversionResult;

  PairConversion({
    required this.result,
    required this.baseCode,
    required this.targetCode,
    required this.conversionRate,
    required this.conversionResult,
  });

  factory PairConversion.fromJson(Map<String, dynamic> json) {
    return PairConversion(
      result: json['result'],
      baseCode: json['base_code'],
      targetCode: json['target_code'],
      conversionRate: (json['conversion_rate'] as num).toDouble(),
      conversionResult: (json['conversion_result'] as num).toDouble(),
    );
  }
}