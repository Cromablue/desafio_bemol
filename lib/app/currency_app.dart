import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../utils/app_colors.dart';

class CurrencyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cotações Financeiras',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: AppColors.primary,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}