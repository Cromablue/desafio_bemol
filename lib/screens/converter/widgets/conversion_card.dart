import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/pair_conversion.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/currency_data.dart';

class ConversionCard extends StatelessWidget {
  final PairConversion result;
  final double originalAmount;

  const ConversionCard({
    super.key,
    required this.result,
    required this.originalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          children: [
            _buildAmountRow(
              context: context,
              label: 'Valor de origem',
              amount: originalAmount,
              symbol: CurrencyData.getCurrencySymbol(result.baseCode),
              code: result.baseCode,
              isResult: false,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Icon(Icons.arrow_downward_rounded, color: Colors.grey.shade400, size: 28),
            ),
            _buildAmountRow(
              context: context,
              label: 'Valor convertido',
              amount: result.conversionResult,
              symbol: CurrencyData.getCurrencySymbol(result.targetCode),
              code: result.targetCode,
              isResult: true,
            ),
            const Divider(height: 32, thickness: 0.5),
            Text(
              'Taxa de câmbio: 1 ${result.baseCode} = ${result.conversionRate.toStringAsFixed(6)} ${result.targetCode}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRow({
    required BuildContext context,
    required String label,
    required double amount,
    required String symbol,
    required String code,
    required bool isResult,
  }) {
    final amountStyle = TextStyle(
      fontSize: isResult ? 32 : 22,
      fontWeight: isResult ? FontWeight.bold : FontWeight.w500,
      color: isResult ? AppColors.primary : Theme.of(context).colorScheme.onSurface,
    );
    final codeStyle = TextStyle(
      fontSize: isResult ? 16 : 14,
      fontWeight: FontWeight.normal,
      color: Colors.grey[700],
    );
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              NumberFormat('#,##0.00', 'pt_BR').format(amount),
              style: amountStyle,
            ),
            const SizedBox(width: 8),
            Text(
              '$symbol ($code)',
              style: codeStyle,
            ),
          ],
        ),
      ],
    );
  }
}