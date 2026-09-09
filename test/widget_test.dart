import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:rentezzi_mobile/core/services/storage_service.dart';
import 'package:rentezzi_mobile/main.dart';
import 'package:rentezzi_mobile/providers/app_provider.dart';
import 'package:rentezzi_mobile/providers/auth_provider.dart';
import 'package:rentezzi_mobile/providers/property_provider.dart';
import 'package:rentezzi_mobile/providers/receipt_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  testWidgets('RentezziApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
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

    expect(find.text('RENTEZZI'), findsOneWidget);

    // Let the splash screen timer finish cleanly
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
  });
}
