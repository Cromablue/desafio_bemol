// screens/currency_list_screen.dart
import 'package:flutter/material.dart';
import '../models/exchange_rates.dart';
import '../services/currency_service.dart';
import '../utils/app_colors.dart';

class CurrencyListScreen extends StatefulWidget {
  @override
  _CurrencyListScreenState createState() => _CurrencyListScreenState();
}

class _CurrencyListScreenState extends State<CurrencyListScreen> {
  ExchangeRates? exchangeRates;
  bool isLoading = true;
  String? error;
  
  // Lista das principais moedas para exibir
  final List<String> mainCurrencies = [
    'BRL', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'CHF', 'CNY', 'MXN', 'ARS'
  ];

  // Nomes das moedas em português
  final Map<String, String> currencyNames = {
    'USD': 'Dólar Americano',
    'BRL': 'Real Brasileiro',
    'EUR': 'Euro',
    'GBP': 'Libra Esterlina',
    'JPY': 'Iene Japonês',
    'CAD': 'Dólar Canadense',
    'AUD': 'Dólar Australiano',
    'CHF': 'Franco Suíço',
    'CNY': 'Yuan Chinês',
    'MXN': 'Peso Mexicano',
    'ARS': 'Peso Argentino',
  };

  @override
  void initState() {
    super.initState();
    fetchExchangeRates();
  }

  Future<void> fetchExchangeRates() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });
      
      final rates = await CurrencyService.getExchangeRates();
      
      setState(() {
        exchangeRates = rates;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cotações USD'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchExchangeRates,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 20),
            Text('Carregando cotações...'),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 20),
            Text(
              'Erro ao carregar cotações',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(error!, textAlign: TextAlign.center),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchExchangeRates,
              child: Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header com informações da atualização
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          color: AppColors.primary.withOpacity(0.1),
          child: Column(
            children: [
              Text(
                'Base: ${exchangeRates!.baseCode}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Última atualização: ${_formatDate(exchangeRates!.timeLastUpdate)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        
        // Lista de cotações
        Expanded(
          child: ListView.builder(
            itemCount: mainCurrencies.length,
            itemBuilder: (context, index) {
              final currencyCode = mainCurrencies[index];
              final rate = exchangeRates!.conversionRates[currencyCode];
              
              if (rate == null) return SizedBox.shrink();
              
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text(
                      currencyCode,
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  title: Text(
                    currencyNames[currencyCode] ?? currencyCode,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('1 USD = ${rate.toStringAsFixed(4)} $currencyCode'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Navegar para detalhes da moeda
                  },
                ),
              );
            },
          ),
        ),
      ],
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