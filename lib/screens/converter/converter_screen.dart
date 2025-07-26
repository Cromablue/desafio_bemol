import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/pair_conversion.dart';
import '../../models/supported_codes.dart';
import '../../services/currency_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/currency_data.dart';
import '../../utils/currency_input_formatter.dart';
import '../../utils/error_handler.dart';
import 'widgets/conversion_card.dart';
import 'widgets/currency_selector_form_field.dart';

class ConverterScreen extends StatefulWidget {
  final List<SupportedCode> supportedCodes;

  const ConverterScreen({
    super.key,
    required this.supportedCodes,
  });

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _fromCurrency = 'BRL';
  String _toCurrency = 'USD';
  bool _isLoading = false;
  PairConversion? _conversionResult;
  String? _error;
  Timer? _debounce;
  final _formatter = CurrencyInputFormatter();
  String _previousAmountText = '';

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onAmountChanged() {
    if (_amountController.text == _previousAmountText) return;
    _previousAmountText = _amountController.text;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), _performConversion);
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
    if (_amountController.text.isNotEmpty) {
      _performConversion();
    }
  }

  Future<void> _performConversion() async {
    if (_amountController.text.isEmpty) {
      setState(() => _conversionResult = null);
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_fromCurrency == _toCurrency) {
      setState(() {
        _error = 'Selecione moedas diferentes.';
        _conversionResult = null;
      });
      return;
    }
    
    setState(() { _isLoading = true; _error = null; });
    
    try {
      final amount = _getAmountFromController();
      final result = await CurrencyService.convertCurrency(from: _fromCurrency, to: _toCurrency, amount: amount);
      if (mounted) setState(() => _conversionResult = result);
    } catch (e) {
      final friendlyError = ErrorHandler.getFriendlyError(e);
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyError), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double _getAmountFromController() {
    String cleanText = _amountController.text.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(cleanText) ?? 0.0;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversor de Moedas'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputCard(),
              const SizedBox(height: 24),
              _buildResultArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Valor',
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Text(
                    CurrencyData.getCurrencySymbol(_fromCurrency),
                    style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _formatter,
              ],
              validator: (value) {
                if (value != null && value.isNotEmpty && _getAmountFromController() <= 0) {
                  return 'Digite um valor maior que zero';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildCurrencySelectors(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencySelectors() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CurrencySelectorFormField(
            label: 'De',
            value: _fromCurrency,
            supportedCodes: widget.supportedCodes,
            onChanged: (val) {
              setState(() => _fromCurrency = val ?? 'BRL');
              if (_amountController.text.isNotEmpty) _performConversion();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
          child: IconButton(
            icon: Icon(Icons.swap_horiz, color: AppColors.primary, size: 32),
            onPressed: _swapCurrencies,
            tooltip: 'Inverter moedas',
          ),
        ),
        Expanded(
          child: CurrencySelectorFormField(
            label: 'Para',
            value: _toCurrency,
            supportedCodes: widget.supportedCodes,
            onChanged: (val) {
              setState(() => _toCurrency = val ?? 'USD');
              if (_amountController.text.isNotEmpty) _performConversion();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultArea() {
    if (_isLoading) {
      return const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(_error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        )
      );
    }
    if (_conversionResult != null) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: ConversionCard(
          key: ValueKey(_conversionResult),
          result: _conversionResult!,
          originalAmount: _getAmountFromController(),
        ),
      );
    }
    return _buildResultPlaceholder();
  }

  Widget _buildResultPlaceholder() {
    return Card(
      key: const ValueKey('placeholder'),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            Icon(Icons.currency_exchange, size: 40, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Digite um valor para iniciar a conversão.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}