import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_elevated_button.dart';
import '../widgets/info_container.dart';
import 'navigation_host_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                _buildMainLogo(),
                const SizedBox(height: 30),
                _buildMainTitle(),
                const SizedBox(height: 10),
                _buildSubtitle(),
                const SizedBox(height: 50),
                _buildNavigationButton(context),
                const SizedBox(height: 20),
                _buildInfoSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainLogo() {
    return SvgPicture.asset(
      'assets/logo.svg',
      height: 120,
      colorFilter: ColorFilter.mode(AppColors.white, BlendMode.srcIn),
    );
  }

  Widget _buildMainTitle() {
    return const Text(
      'BSF Câmbio',
      style: TextStyle(
        color: AppColors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    return const Text(
      'Sua plataforma para cotações de moedas em tempo real. Acompanhe, compare e planeje.',
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
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NavigationHostScreen()),
        );
      },
    );
  }

  Widget _buildInfoSection() {
    return const InfoContainer(
      icon: Icons.info_outline,
      text: 'Dados fornecidos em tempo real',
    );
  }
}