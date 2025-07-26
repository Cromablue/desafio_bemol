import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/supported_codes.dart';
import '../utils/app_colors.dart';
import '../utils/currency_data.dart';
import '../utils/currency_input_formatter.dart';

class CurrencyDetailScreen extends StatefulWidget {
  final SupportedCode currency;
  final double rate;
  final String baseCode;
  final int lastUpdate;
  final bool isVolatile;
  final List<SupportedCode> supportedCodes;

  const CurrencyDetailScreen({
    super.key,
    required this.currency,
    required this.rate,
    required this.baseCode,
    required this.lastUpdate,
    required this.isVolatile,
    required this.supportedCodes,
  });

  @override
  State<CurrencyDetailScreen> createState() => _CurrencyDetailScreenState();
}

class _CurrencyDetailScreenState extends State<CurrencyDetailScreen> {
  late final TextEditingController _baseAmountController;
  late final TextEditingController _targetAmountController;
  final _formatter = CurrencyInputFormatter();
  bool _isEditingBase = true;
  String _previousBaseText = '';
  String _previousTargetText = '';

  @override
  void initState() {
    super.initState();
    final rateFormatter = NumberFormat('#,##0.00', 'pt_BR');
    _baseAmountController = TextEditingController(text: "1,00");
    _targetAmountController = TextEditingController(text: rateFormatter.format(widget.rate));
    _previousBaseText = _baseAmountController.text;
    _previousTargetText = _targetAmountController.text;
    _baseAmountController.addListener(_onBaseAmountChanged);
    _targetAmountController.addListener(_onTargetAmountChanged);
  }

  @override
  void dispose() {
    _baseAmountController.removeListener(_onBaseAmountChanged);
    _targetAmountController.removeListener(_onTargetAmountChanged);
    _baseAmountController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  void _onBaseAmountChanged() {
    if (!_isEditingBase || _baseAmountController.text == _previousBaseText) return;
    _previousBaseText = _baseAmountController.text;
    _updateTextField(_targetAmountController);
  }

  void _onTargetAmountChanged() {
    if (_isEditingBase || _targetAmountController.text == _previousTargetText) return;
    _previousTargetText = _targetAmountController.text;
    _updateTextField(_baseAmountController);
  }

  double _getAmountFromController(TextEditingController controller) {
    String cleanText = controller.text.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(cleanText) ?? 0.0;
  }

  void _updateTextField(TextEditingController controller) {
    if (widget.rate == 0) return;
    
    final double result = _isEditingBase
        ? _getAmountFromController(_baseAmountController) * widget.rate
        : _getAmountFromController(_targetAmountController) / widget.rate;
    
    final formattedValue = NumberFormat('#,##0.00', 'pt_BR').format(result);

    controller.value = controller.value.copyWith(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );

    _previousBaseText = _baseAmountController.text;
    _previousTargetText = _targetAmountController.text;
  }

  String _formatLastUpdate() {
    try {
      final updateTime = DateTime.fromMillisecondsSinceEpoch(widget.lastUpdate * 1000);
      return DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(updateTime.toLocal());
    } catch (e) {
      return 'Data indisponível';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.currency.code} / ${widget.baseCode}'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.isVolatile) _buildVolatilityWarning(),
              _buildInteractiveConverterCard(context),
              const SizedBox(height: 24),
              _buildInfoPanel(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveConverterCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          children: [
            _buildAmountInput(
              context: context,
              controller: _baseAmountController,
              code: widget.baseCode,
              onTap: () => setState(() => _isEditingBase = true),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Icon(Icons.swap_vert_rounded, color: Colors.grey, size: 32),
            ),
            _buildAmountInput(
              context: context,
              controller: _targetAmountController,
              code: widget.currency.code,
              onTap: () => setState(() => _isEditingBase = false),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAmountInput({
    required BuildContext context,
    required TextEditingController controller,
    required String code,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: controller,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: CurrencyData.getFullName(code, code),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Text(
            CurrencyData.getCurrencySymbol(code),
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
    );
  }
  
  Widget _buildInfoPanel(BuildContext context) {
    String volatilityText = widget.isVolatile ? 'Alta' : 'Baixa a Moderada';
    Color volatilityColor = widget.isVolatile ? Colors.orange.shade700 : Colors.green.shade700;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações da Moeda',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const Divider(height: 24),
            _buildInfoRow('Taxa de Câmbio (Precisa):', text: widget.rate.toStringAsFixed(6)),
            _buildInfoRow('Volatilidade:', text: volatilityText, textColor: volatilityColor),
            _buildInfoRow('Atualizado:', text: _formatLastUpdate()),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, {String? text, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          if (text != null)
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor ?? Colors.black87,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVolatilityWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Aviso: Moeda com alta volatilidade.',
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}