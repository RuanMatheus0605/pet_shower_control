import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'providers/appointment_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('pt_BR', null).then((_) {
    runApp(
      ChangeNotifierProvider(
        create: (_) => AppointmentProvider(),
        child: const MainApp(),
      ),
    );
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryCaramel = Color(0xFFD4A373);
    const darkSlate = Color(0xFF2A3439);

    return MaterialApp(
      title: 'Pet Shower Control',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: primaryCaramel,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryCaramel,
          primary: primaryCaramel,
          surface: Colors.white,
          onSurface: darkSlate,
        ),
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: darkSlate,
              displayColor: darkSlate,
            ),
      ),
      home: const HomeScreen(),
    );
  }
}
