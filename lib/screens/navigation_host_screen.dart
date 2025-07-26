import 'package:flutter/material.dart';
import '../models/supported_codes.dart';
import '../services/currency_service.dart';
import '../utils/app_colors.dart';
import '../utils/error_handler.dart';
import '../widgets/custom_elevated_button.dart';
import 'converter/converter_screen.dart';
import 'currency_list_screen.dart';

class NavigationHostScreen extends StatefulWidget {
  const NavigationHostScreen({super.key});

  @override
  State<NavigationHostScreen> createState() => _NavigationHostScreenState();
}

class _NavigationHostScreenState extends State<NavigationHostScreen> {
  int _currentIndex = 0;
  List<SupportedCode> _supportedCodes = [];
  bool _isLoadingCodes = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSupportedCodes();
  }

  Future<void> _fetchSupportedCodes() async {
    if (!mounted) return;
    setState(() {
      _isLoadingCodes = true;
      _error = null;
    });

    try {
      final codes = await CurrencyService.getSupportedCodes();
      if (mounted) {
        setState(() {
          _supportedCodes = codes;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = ErrorHandler.getFriendlyError(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCodes = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded),
            label: 'Cotações',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz_rounded),
            label: 'Conversor',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoadingCodes) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_outlined, color: Colors.grey[500], size: 80),
              const SizedBox(height: 20),
              const Text(
                'Falha ao Carregar Dados',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 30),
              CustomElevatedButton(
                text: 'Tentar Novamente',
                onPressed: _fetchSupportedCodes,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              )
            ],
          ),
        ),
      );
    }

    final List<Widget> pages = [
      CurrencyListScreen(supportedCodes: _supportedCodes),
      ConverterScreen(supportedCodes: _supportedCodes),
    ];

    return IndexedStack(
      index: _currentIndex,
      children: pages,
    );
  }
}