// screens/currency_detail_screen.dart
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CurrencyDetailScreen extends StatelessWidget {
  final String currencyCode;
  final String currencyName;
  final double rate;
  final String baseCode;
  final String lastUpdate;

  const CurrencyDetailScreen({
    Key? key,
    required this.currencyCode,
    required this.currencyName,
    required this.rate,
    required this.baseCode,
    required this.lastUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currencyCode),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card principal com a cotação
            Card(
              elevation: 4,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      currencyName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Text(
                      '1 $baseCode =',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '${rate.toStringAsFixed(4)} $currencyCode',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 30),
            
            // Informações adicionais
            Text(
              'Informações',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            
            _buildInfoRow('Moeda base:', baseCode),
            _buildInfoRow('Moeda cotada:', currencyCode),
            _buildInfoRow('Taxa de câmbio:', rate.toStringAsFixed(6)),
            _buildInfoRow('Última atualização:', _formatDate(lastUpdate)),
            
            SizedBox(height: 30),
            
            // Conversão reversa
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Conversão reversa',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '1 $currencyCode = ${(1/rate).toStringAsFixed(6)} $baseCode',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}