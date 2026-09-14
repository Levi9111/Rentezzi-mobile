import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rentezzi_mobile/core/constants/api_endpoints.dart';
import 'package:rentezzi_mobile/core/services/api_service.dart';
import 'package:rentezzi_mobile/core/services/storage_service.dart';
import 'package:rentezzi_mobile/providers/app_provider.dart';
import 'package:rentezzi_mobile/widgets/rentezzi_logo.dart';
import 'package:rentezzi_mobile/widgets/server_settings_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  group('Logo & Brand Asset Tests', () {
    testWidgets('RentezziLogo renders with correct sizing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: RentezziLogo(size: 80),
            ),
          ),
        ),
      );

      expect(find.byType(RentezziLogo), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('RentezziLogo with hero tag renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: RentezziLogo(size: 100, useHero: true),
            ),
          ),
        ),
      );

      expect(find.byType(Hero), findsOneWidget);
    });
  });

  group('Network & BaseUrl Configuration Tests', () {
    test('Default baseUrl points to Render production', () {
      expect(ApiService.baseUrl, equals(ApiEndpoints.baseUrl));
    });

    test('Custom baseUrl overrides default', () async {
      const customUrl = 'http://192.168.1.105:5000/api/v1';
      await ApiService.setBaseUrl(customUrl);
      expect(ApiService.baseUrl, equals(customUrl));

      // Reset
      await ApiService.resetBaseUrl();
      expect(ApiService.baseUrl, equals(ApiEndpoints.baseUrl));
    });

    testWidgets('ServerSettingsDialog displays presets and allows editing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppProvider()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: ServerSettingsDialog(),
            ),
          ),
        ),
      );

      expect(find.text('Server Configuration'), findsOneWidget);
      expect(find.text('Cloud (Render)'), findsOneWidget);
      expect(find.text('Android Emulator'), findsOneWidget);
      expect(find.text('Localhost'), findsOneWidget);
      expect(find.text('Test Connection'), findsOneWidget);
      expect(find.text('Save & Apply'), findsOneWidget);
    });
  });
}
