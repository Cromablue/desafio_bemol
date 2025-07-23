import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_elevated_button.dart';
import '../widgets/info_container.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMainIcon(),
                SizedBox(height: 30),
                _buildMainTitle(),
                SizedBox(height: 10),
                _buildSubtitle(),
                SizedBox(height: 50),
                _buildNavigationButton(context),
                SizedBox(height: 20),
                _buildInfoSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainIcon() {
    return Icon(
      Icons.monetization_on,
      size: 120,
      color: AppColors.white,
    );
  }

  Widget _buildMainTitle() {
    return Text(
      'Cotações Financeiras',
      style: TextStyle(
        color: AppColors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Acompanhe as cotações das principais moedas em tempo real',
      style: TextStyle(
        color: AppColors.white70,
        fontSize: 18,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildNavigationButton(BuildContext context) {
    return CustomElevatedButton(
      text: 'Ver Cotações',
      onPressed: () => _showDevelopmentMessage(context),
    );
  }

  Widget _buildInfoSection() {
    return InfoContainer(
      icon: Icons.info_outline,
      text: 'Dados via exchangerate-api.com',
    );
  }

  void _showDevelopmentMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Funcionalidade em desenvolvimento!'),
        backgroundColor: AppColors.snackBarWarning,
      ),
    );
  }
}