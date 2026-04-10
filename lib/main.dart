import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/task_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NhacViecApp());
}

class NhacViecApp extends StatelessWidget {
  const NhacViecApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nhắc Việc',
      debugShowCheckedModeBanner: false,
      locale: const Locale('vi', 'VN'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi', 'VN'),
        Locale('en', 'US'),
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90E2),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4A90E2),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF4A90E2),
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
      home: const TaskListScreen(),
    );
  }
}