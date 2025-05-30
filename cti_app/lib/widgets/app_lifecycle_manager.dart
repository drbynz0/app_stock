import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '/screens/settings_pages/pin_code_screen.dart';

class AppLifecycleManager extends StatefulWidget {
  final Widget child;

  const AppLifecycleManager({super.key, required this.child});

  @override
  State<AppLifecycleManager> createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends State<AppLifecycleManager> 
    with WidgetsBindingObserver {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _shouldCheckAuth = true;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _shouldCheckAuth) {
      _checkAuthAndNavigate();
    } else if (state == AppLifecycleState.paused) {
      _shouldCheckAuth = true; // Réactive la vérification au prochain resumed
    }
  }

  Future<void> _checkAuthAndNavigate() async {
    _shouldCheckAuth = false; // Empêche les vérifications multiples
    
    final pin = await _secureStorage.read(key: 'user_pin');
    final token = await _secureStorage.read(key: 'access_token');

    final bool isLoggedIn = token != null;
    final bool hasPin = pin != null && pin.length == 4;
    final bool isPinEnabled = await _secureStorage.read(key: 'pin_enabled') == 'true';

    if (isLoggedIn && isPinEnabled && hasPin && _navigatorKey.currentState != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const PinCodeScreen(),
            fullscreenDialog: true,
          ),
          (route) => false,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      home: widget.child,
    );
  }
}