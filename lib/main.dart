import 'package:flutter/material.dart';
import 'screens/stocks.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MultiBox',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0, // Prevent elevation tinting
          foregroundColor: Colors.black, // For text and icons
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ).copyWith(surfaceTint: Colors.transparent), // Removes overlay effect
      ),
      home: const StocksScreen(title: "Stocks",),
    );
  }
}
