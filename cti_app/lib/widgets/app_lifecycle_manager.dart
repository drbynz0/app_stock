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
  BuildContext? _navigationContext;

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
      _shouldCheckAuth = true;
    }
  }

  Future<void> _checkAuthAndNavigate() async {
    if (!_shouldCheckAuth || !mounted) return;
    _shouldCheckAuth = false;
    
    try {
      final pin = await _secureStorage.read(key: 'user_pin');
      final token = await _secureStorage.read(key: 'access_token');
      final isPinEnabled = await _secureStorage.read(key: 'pin_enabled') == 'true';

      final bool isLoggedIn = token != null;
      final bool hasPin = pin != null && pin.length == 4;

      if (isLoggedIn && isPinEnabled && hasPin && _navigationContext != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_navigationContext != null && mounted) {
            Navigator.of(_navigationContext!).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const PinCodeScreen(),
                fullscreenDialog: true,
              ),
              (route) => false,
            );
          }
        });
      }
    } catch (e) {
      debugPrint('Error in _checkAuthAndNavigate: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        _navigationContext = context;
        return widget.child;
      },
    );
  }
}