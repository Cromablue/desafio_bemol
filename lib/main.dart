import 'package:flutter/material.dart';

void main() {
  runApp(CurrencyApp());
}

class CurrencyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cotações Financeiras',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.monetization_on,
                  size: 120,
                  color: Colors.white,
                ),
                SizedBox(height: 30),
                
                Text(
                  'BSF Cotações Financeiras',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                
                // Subtítulo
                Text(
                  'Acompanhe as cotações das principais moedas em tempo real',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 50),

                // Botão para navegar para a lista de cotações
                ElevatedButton(
                  onPressed: () {
                    // Placeholder para a navegação
                  },
                  child: Text('Ver Cotações'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}