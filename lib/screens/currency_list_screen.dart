import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exchange_rates.dart';
import '../models/supported_codes.dart';
import '../services/currency_service.dart';
import '../utils/app_colors.dart';
import '../utils/currency_data.dart';
import '../utils/error_handler.dart';
import 'currency_detail_screen.dart';

/// Classe auxiliar usada pelo algoritmo de busca para pontuar a relevância.
class _ScoredCurrency {
  final SupportedCode currency;
  final int score;
  _ScoredCurrency(this.currency, this.score);
}

/// Enum para os critérios de ordenação da lista.
enum SortCriteria { name, value }

class CurrencyListScreen extends StatefulWidget {
  final List<SupportedCode> supportedCodes;
  const CurrencyListScreen({super.key, required this.supportedCodes});

  @override
  CurrencyListScreenState createState() => CurrencyListScreenState();
}

class CurrencyListScreenState extends State<CurrencyListScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  ExchangeRates? exchangeRates;
  bool isLoading = true;
  String? error;
  String _selectedBaseCurrency = 'BRL';
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  List<SupportedCode> _filteredCurrencies = [];
  Timer? _debounce;
  final _rateFormatter = NumberFormat('#,##0.00', 'pt_BR');

  SortCriteria _sortCriteria = SortCriteria.name;
  bool _isAscending = true;

  TabController? _tabController;
  Set<String> _favorites = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);
    _filteredCurrencies = widget.supportedCodes;
    _searchController.addListener(_onSearchChanged);

    _tabController?.addListener(_onTabChanged);
    _searchFocusNode.addListener(_onSearchFocusChanged);

    _loadFavorites().then((_) {
      fetchExchangeRates();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController?.removeListener(_onTabChanged);
    _tabController?.dispose();
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchFocusNode.dispose();
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
      _searchFocusNode.unfocus();
      FocusScope.of(context).unfocus();
    }
  }

  void _onTabChanged() {
    if (_tabController?.indexIsChanging ?? false) {
      _dismissAllSelections();
    }
  }

  void _onSearchFocusChanged() {
    if (!_searchFocusNode.hasFocus) {
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _filterCurrencies);
  }

  void _filterCurrencies() {
    final query = _searchController.text.toLowerCase().trim();
    List<SupportedCode> baseList = widget.supportedCodes;
    if (query.isEmpty) {
      _filteredCurrencies = baseList;
    } else {
      final normalizedQuery = CurrencyData.normalize(query);
      final scoredCurrencies = baseList.map((currency) {
        final fullName = CurrencyData.getFullName(currency.code, currency.name);
        final normalizedName = CurrencyData.normalize(fullName.toLowerCase());
        final codeLower = currency.code.toLowerCase();
        int score = 0;
        if (codeLower == normalizedQuery) {
          score = 100;
        } else if (codeLower.startsWith(normalizedQuery)) {
          score = 90;
        } else if (normalizedName.startsWith(normalizedQuery)) {
          score = 80;
        } else if (normalizedName.contains(normalizedQuery)) {
          score = 50;
        }
        return _ScoredCurrency(currency, score);
      }).where((item) => item.score > 0).toList();
      scoredCurrencies.sort((a, b) => b.score.compareTo(a.score));
      _filteredCurrencies = scoredCurrencies.map((item) => item.currency).toList();
    }
    _sortCurrencies();
    if (mounted) {
      setState(() {});
    }
  }

  void _sortCurrencies() {
    _filteredCurrencies.sort((a, b) {
      int comparison;
      if (_sortCriteria == SortCriteria.name) {
        final nameA = CurrencyData.getFullName(a.code, a.name);
        final nameB = CurrencyData.getFullName(b.code, b.name);
        comparison = nameA.compareTo(nameB);
      } else {
        final rateA = exchangeRates?.conversionRates[a.code] ?? 0.0;
        final rateB = exchangeRates?.conversionRates[b.code] ?? 0.0;
        comparison = rateA.compareTo(rateB);
      }
      return _isAscending ? comparison : -comparison;
    });
  }

  void _onSortChanged(SortCriteria criteria) {
    _dismissAllSelections();
    setState(() {
      if (_sortCriteria == criteria) {
        _isAscending = !_isAscending;
      } else {
        _sortCriteria = criteria;
        _isAscending = true;
      }
      _sortCurrencies();
    });
  }

  Future<void> fetchExchangeRates({String? newBaseCurrency}) async {
    if (newBaseCurrency != null) _selectedBaseCurrency = newBaseCurrency;
    try {
      if (mounted) {
        setState(() {
          isLoading = true;
          error = null;
        });
      }
      final rates = await CurrencyService.getExchangeRatesWithCache(
          baseCurrency: _selectedBaseCurrency);
      if (mounted) {
        setState(() {
          exchangeRates = rates;
          _sortCurrencies();
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = ErrorHandler.getFriendlyError(e));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _toggleFavorite(String code) {
    setState(() {
      if (_favorites.contains(code)) {
        _favorites.remove(code);
      } else {
        _favorites.add(code);
      }
    });
    _saveFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteCodes = prefs.getStringList('favorite_currencies');
    if (favoriteCodes != null && mounted) {
      setState(() {
        _favorites = favoriteCodes.toSet();
      });
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_currencies', _favorites.toList());
  }

  Future<void> _navigateToDetail(SupportedCode currency, double rate, bool isVolatile) async {
    _dismissAllSelections();

    await Future.delayed(const Duration(milliseconds: 100));

    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CurrencyDetailScreen(
            currency: currency,
            rate: rate,
            baseCode: _selectedBaseCurrency,
            lastUpdate: exchangeRates!.timeLastUpdate,
            isVolatile: isVolatile,
            supportedCodes: widget.supportedCodes,
          ),
        ),
      );

      if (mounted) {
        _dismissAllSelections();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTap: () => _dismissAllSelections(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mercado de Câmbio'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'TODAS AS MOEDAS'),
              Tab(text: 'FAVORITAS'),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildListHeader(),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : error != null
                      ? _buildErrorState(error!)
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildCurrencyList(_filteredCurrencies),
                            _buildCurrencyList(_filteredCurrencies.where((c) => _favorites.contains(c.code)).toList()),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          const Text('Moeda Base:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _openBaseCurrencySelector,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$_selectedBaseCurrency - ${_getBaseCurrencyName()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getBaseCurrencyName() {
    try {
      final baseCurrency = widget.supportedCodes.firstWhere(
        (c) => c.code == _selectedBaseCurrency,
      );
      return CurrencyData.getFullName(_selectedBaseCurrency, baseCurrency.name);
    } catch (e) {
      return _selectedBaseCurrency; // fallback
    }
  }

  Future<void> _openBaseCurrencySelector() async {
    FocusScope.of(context).unfocus();
    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: ListView.separated(
            itemCount: widget.supportedCodes.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final currency = widget.supportedCodes[index];
              return ListTile(
                selected: _selectedBaseCurrency == currency.code,
                selectedColor: AppColors.primary,
                title: Text(currency.code, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(CurrencyData.getFullName(currency.code, currency.name)),
                onTap: () => Navigator.pop(context, currency.code),
                trailing: _selectedBaseCurrency == currency.code
                    ? Icon(Icons.check, color: AppColors.primary)
                    : null,
              );
            },
          ),
        );
      },
    );
    if (selected != null && selected != _selectedBaseCurrency) {
      setState(() {
        _selectedBaseCurrency = selected;
        error = null;
      });
      await fetchExchangeRates(newBaseCurrency: selected);
    }
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _searchController,
        builder: (_, value, __) {
          return TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Buscar por nome ou código...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: value.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterCurrencies(); // Atualiza lista após limpar o campo
                        _searchFocusNode.unfocus();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onSubmitted: (_) {
              _searchFocusNode.unfocus();
            },
          );
        },
      ),
    );
  }

  Widget _buildListHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSortableHeader('MOEDA', SortCriteria.name),
          _buildSortableHeader('VALOR (1 $_selectedBaseCurrency)', SortCriteria.value),
        ],
      ),
    );
  }

  Widget _buildSortableHeader(String title, SortCriteria criteria) {
    final bool isActive = _sortCriteria == criteria;
    return InkWell(
      onTap: () => _onSortChanged(criteria),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive ? AppColors.primary : Colors.grey.shade600,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              Icon(
                _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 14,
                color: AppColors.primary,
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyList(List<SupportedCode> currencies) {
    if (currencies.isEmpty) {
      bool isFavoritesTab = _tabController?.index == 1;
      return _buildEmptyList(isFavoritesTab: isFavoritesTab);
    }
    final validCurrencies = currencies.where((currency) {
      if (currency.code == _selectedBaseCurrency) return false;
      return exchangeRates?.conversionRates[currency.code] != null;
    }).toList();
    return RefreshIndicator(
      onRefresh: () async {
        _dismissAllSelections();
        await fetchExchangeRates();
      },
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: validCurrencies.length,
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
        itemBuilder: (context, index) {
          final currency = validCurrencies[index];
          final rate = exchangeRates!.conversionRates[currency.code]!;
          final isVolatile = CurrencyData.volatileCurrencies.contains(currency.code);
          return _buildCurrencyTile(currency, rate, isVolatile);
        },
      ),
    );
  }

  Widget _buildCurrencyTile(SupportedCode currency, double rate, bool isVolatile) {
    final isFavorite = _favorites.contains(currency.code);
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 4, right: 16, top: 8, bottom: 8),
      leading: IconButton(
        icon: Icon(
          isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
          color: isFavorite ? Colors.amber.shade700 : Colors.grey.shade400,
        ),
        onPressed: () => _toggleFavorite(currency.code),
        tooltip: isFavorite ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
      ),
      title: Text(
        '${CurrencyData.getFullName(currency.code, currency.name)} (${currency.code})',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: Text(
        _rateFormatter.format(rate),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
      ),
      onTap: () => _navigateToDetail(currency, rate, isVolatile),
    );
  }

  Widget _buildEmptyList({bool isFavoritesTab = false}) {
    if (isFavoritesTab) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('Nenhuma moeda favorita', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              "Toque na estrela para adicionar moedas aqui.",
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return _buildEmptySearchResult();
  }

  Widget _buildEmptySearchResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('Nenhuma moeda encontrada', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Tente usar um termo de busca diferente.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[300], size: 80),
            const SizedBox(height: 20),
            const Text('Ocorreu um Erro', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
              onPressed: () {
                _dismissAllSelections();
                fetchExchangeRates();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
