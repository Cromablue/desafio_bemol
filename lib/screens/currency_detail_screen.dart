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

class _CurrencyDetailScreenState extends State<CurrencyDetailScreen>
    with WidgetsBindingObserver {
  late final TextEditingController _baseAmountController;
  late final TextEditingController _targetAmountController;
  final _baseFocusNode = FocusNode();
  final _targetFocusNode = FocusNode();
  final _formatter = CurrencyInputFormatter();
  bool _isEditingBase = true;
  String _previousBaseText = '';
  String _previousTargetText = '';

  String _fromCurrency = '';
  String _toCurrency = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _fromCurrency = widget.baseCode;
    _toCurrency = widget.currency.code;

    final rateFormatter = NumberFormat('#,##0.00', 'pt_BR');
    _baseAmountController = TextEditingController(text: "1,00");
    _targetAmountController = TextEditingController(text: rateFormatter.format(widget.rate));

    _previousBaseText = _baseAmountController.text;
    _previousTargetText = _targetAmountController.text;

    _baseAmountController.addListener(_onBaseAmountChanged);
    _targetAmountController.addListener(_onTargetAmountChanged);

    _baseFocusNode.addListener(_onBaseFocusChanged);
    _targetFocusNode.addListener(_onTargetFocusChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _baseAmountController.removeListener(_onBaseAmountChanged);
    _targetAmountController.removeListener(_onTargetAmountChanged);
    _baseFocusNode.removeListener(_onBaseFocusChanged);
    _targetFocusNode.removeListener(_onTargetFocusChanged);

    _baseAmountController.dispose();
    _targetAmountController.dispose();
    _baseFocusNode.dispose();
    _targetFocusNode.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _dismissAllSelections();
    }
  }

  void _dismissAllSelections() {
    if (mounted) {
      _baseFocusNode.unfocus();
      _targetFocusNode.unfocus();
      FocusScope.of(context).unfocus();
    }
  }

  void _onBaseFocusChanged() {
    if (_baseFocusNode.hasFocus) {
      setState(() => _isEditingBase = true);
      _targetFocusNode.unfocus();
    }
  }

  void _onTargetFocusChanged() {
    if (_targetFocusNode.hasFocus) {
      setState(() => _isEditingBase = false);
      _baseFocusNode.unfocus();
    }
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

  // Abre modal para seleção de moeda, isFromCurrency indica se é moeda "De" ou "Para"
  Future<void> _openCurrencySelector(bool isFromCurrency) async {
    FocusScope.of(context).unfocus(); // fecha teclado

    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: widget.supportedCodes.length,
          itemBuilder: (context, index) {
            final currency = widget.supportedCodes[index];
            return ListTile(
              title: Text(currency.code),
              subtitle: Text(CurrencyData.getFullName(currency.code, currency.name)),
              onTap: () => Navigator.pop(context, currency.code),
            );
          },
        );
      },
    );

    if (selected != null) {
      setState(() {
        if (isFromCurrency) {
          _fromCurrency = selected;
        } else {
          _toCurrency = selected;
        }
      });
    }
  }

  void _swapCurrencies() {
    _dismissAllSelections();

    final tempText = _baseAmountController.text;
    _baseAmountController.text = _targetAmountController.text;
    _targetAmountController.text = tempText;

    final tempCurrency = _fromCurrency;
    _fromCurrency = _toCurrency;
    _toCurrency = tempCurrency;

    _previousBaseText = _baseAmountController.text;
    _previousTargetText = _targetAmountController.text;

    setState(() {
      _isEditingBase = !_isEditingBase;
    });
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
    return GestureDetector(
      onTap: () => _dismissAllSelections(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.currency.code} / ${widget.baseCode}'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.isVolatile) _buildVolatilityWarning(),
              _buildConverterCard(),
              const SizedBox(height: 16),
              _buildResultCard(),
              const SizedBox(height: 16),
              _buildAnalysisCard(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConverterCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de valor principal
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Valor',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Text(
                          _fromCurrency,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _baseAmountController,
                          focusNode: _baseFocusNode,
                          textAlign: TextAlign.right,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _formatter,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Currency selectors and swap button with improved swap style
            Row(
              children: [
                Expanded(
                  child: _buildCurrencySelector(
                    label: 'De',
                    value: _fromCurrency,
                    onTap: () => _openCurrencySelector(true),
                  ),
                ),
                const SizedBox(width: 16),
                Material(
                  shape: const CircleBorder(),
                  color: Colors.white,
                  elevation: 2,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _swapCurrencies,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.swap_horiz,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCurrencySelector(
                    label: 'Para',
                    value: _toCurrency,
                    onTap: () => _openCurrencySelector(false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencySelector({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '$value - ${CurrencyData.getFullName(value, value).split(' ').take(2).join(' ')}...',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard() {
    final baseAmount = _getAmountFromController(_baseAmountController);
    final targetAmount = _getAmountFromController(_targetAmountController);
    final rateFormatter = NumberFormat('#,##0.00', 'pt_BR');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'VALOR DE ORIGEM',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${rateFormatter.format(baseAmount)} ${CurrencyData.getCurrencySymbol(_fromCurrency)} ($_fromCurrency)',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey.shade400,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              'VALOR CONVERTIDO',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${rateFormatter.format(targetAmount)} ${CurrencyData.getCurrencySymbol(_toCurrency)} ($_toCurrency)',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Taxa de câmbio: 1 $_fromCurrency = ${(targetAmount / baseAmount).toStringAsFixed(5)} $_toCurrency',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard() {
    String volatilityText = widget.isVolatile ? 'Alta' : 'Baixa a Moderada';
    Color volatilityColor = widget.isVolatile ? Colors.orange.shade700 : Colors.green.shade700;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Análise da Moeda',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 16),
            _buildAnalysisRow('Taxa de Câmbio (Precisa):', widget.rate.toStringAsFixed(6)),
            const SizedBox(height: 12),
            _buildAnalysisRow('Volatilidade:', volatilityText, textColor: volatilityColor),
            const SizedBox(height: 12),
            _buildAnalysisRow('Atualizado:', _formatLastUpdate()),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisRow(String label, String value, {Color? textColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildVolatilityWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withOpacity(0.1),
            Colors.orange.withOpacity(0.05),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange.shade800,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Atenção: Alta Volatilidade',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Esta moeda pode apresentar variações significativas.',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
