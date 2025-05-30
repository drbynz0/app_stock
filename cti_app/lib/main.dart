import 'package:cti_app/controller/login_controller.dart';
import 'package:cti_app/services/category_service.dart';
import 'package:cti_app/services/client_service.dart';
import 'package:cti_app/services/discount_service.dart';
import 'package:cti_app/services/external_order_service.dart';
import 'package:cti_app/services/internal_order_service.dart';
import 'package:cti_app/services/profile_service.dart';
import 'package:cti_app/services/product_service.dart';
import 'package:cti_app/theme/theme_provider.dart';
import 'package:cti_app/widgets/app_lifecycle_manager.dart';
import 'package:cti_app/widgets/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/screens/login_screen.dart';
import '/screens/welcome_screen.dart';
import '/screens/pin_code_screen.dart';
import 'screens/home_screen.dart';
import 'services/app_data_service.dart';
import 'package:provider/provider.dart';
import '/services/activity_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

  const secureStorage = FlutterSecureStorage();
  final authController = AuthController();
  final bool isLoggedIn = await authController.isLoggedIn();
  final bool isPinEnabled = await secureStorage.read(key: 'pin_enabled') == 'true';
  final savedPin = await secureStorage.read(key: 'user_pin');

  runApp(
    ConnectivityWrapper(
      child: MultiProvider(
        providers: [
        ChangeNotifierProvider(create: (_) => AppData()),
        ChangeNotifierProvider(create: (_) => ActivityService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => InternalOrderService()),
        ChangeNotifierProvider(create: (_) => ClientService()),
        ChangeNotifierProvider(create: (_) => ExternalOrderService()),
        ChangeNotifierProvider(create: (_) => DiscountService()),
        ChangeNotifierProvider(create: (_) => ProductService()),
        ChangeNotifierProvider(create: (_) => CategoryService()),
        ChangeNotifierProvider(create: (_) => ProfileService()),
        ],
        child: AppLifecycleManager(
          child: MyApp(
            isFirstLaunch: isFirstLaunch,
            isLoggedIn: isLoggedIn,
            isPinEnabled: isPinEnabled,
            hasPin: savedPin != null && savedPin.length == 4,
          ),
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isFirstLaunch;
  final bool isLoggedIn;
  final bool isPinEnabled;
  final bool hasPin;

  const MyApp({
    super.key,
    required this.isFirstLaunch,
    required this.isLoggedIn,
    required this.isPinEnabled,
    required this.hasPin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    Widget initialScreen;

    if (isFirstLaunch) {
      initialScreen = const WelcomeScreen();
    } else if (isLoggedIn) {
      if (isPinEnabled && hasPin) {
        initialScreen = const PinCodeScreen();
      } else {
        initialScreen = const HomeScreen();
      }
    } else {
      initialScreen = const LoginScreen();
    }

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CTI TECHNOLOGIE',
          theme: theme.themeData,
          darkTheme: theme.buildDarkTheme(),
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: initialScreen,
          routes: {
            '/welcome': (context) => const WelcomeScreen(),
            '/login': (context) => const LoginScreen(),
            '/home': (context) => const HomeScreen(),
            '/pin': (context) => const PinCodeScreen(),
          },
        );
      },
    );
  }
}