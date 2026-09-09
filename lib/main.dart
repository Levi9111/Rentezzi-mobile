import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/property_provider.dart';
import 'providers/receipt_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PropertyProvider()),
        ChangeNotifierProvider(create: (_) => ReceiptProvider()),
      ],
      child: const RentezziApp(),
    ),
  );
}

class RentezziApp extends StatelessWidget {
  const RentezziApp({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    return MaterialApp(
      title: 'Rentezzi - ভাড়ার হিসাব',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(fontScale: app.fontScale),
      darkTheme: AppTheme.darkTheme(fontScale: app.fontScale),
      themeMode: app.themeMode,
      home: const SplashScreen(),
    );
  }
}
