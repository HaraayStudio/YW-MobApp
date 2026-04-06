import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'models/app_models.dart';
import 'screens/splash_screen.dart';   // ← fixed splash (no white flash)
import 'screens/auth_screens.dart';
import 'screens/main_app_screen.dart';
import 'services/token_service.dart';
import 'services/auth_service.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TokenService.init();

  // Lock to portrait to eliminate layout pixel issues on tablets
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar: transparent + dark icons (matches surface #F9FBEC)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  runApp(const YWArchitectsApp());
}

class YWArchitectsApp extends StatelessWidget {
  const YWArchitectsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          title: 'YW Architects',
          debugShowCheckedModeBanner: false,
          scrollBehavior: _NoGlowScrollBehavior(),
          theme: AppTheme.theme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          home: const AppRoot(),
        );
      },
    );
  }
}

// ── Scroll behaviour — removes stretch overscroll glow ──────────────────────
class _NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child; // no glow / stretch effect
  }
}

// ── App state machine ────────────────────────────────────────────────────────
enum _AppState { splash, login, forgotPassword, main }

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  _AppState _state = _AppState.splash;
  AppUser?  _currentUser;

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  void _checkAutoLogin() {
    final user = AuthService.tryAutoLogin();
    if (user != null) {
      _currentUser = user;
    }
  }

  void _onSplashComplete() {
    setState(() {
      _state = _currentUser != null ? _AppState.main : _AppState.login;
    });
  }
  void _onForgotPassword()  => setState(() => _state = _AppState.forgotPassword);
  void _onBackToLogin()     => setState(() => _state = _AppState.login);

  void _onLogin(AppUser user) => setState(() {
    _currentUser = user;
    _state = _AppState.main;
  });

  void _onLogout() => setState(() {
    AuthService.logout();
    _currentUser = null;
    _state = _AppState.login;
  });

  @override
  Widget build(BuildContext context) {
    switch (_state) {
      case _AppState.splash:
        return SplashScreen(onComplete: _onSplashComplete);

      case _AppState.login:
        return LoginScreen(
          onLogin: _onLogin,
          onForgotPassword: _onForgotPassword,
        );

      case _AppState.forgotPassword:
        return ForgotPasswordScreen(onBack: _onBackToLogin);

      case _AppState.main:
        if (_currentUser == null) {
          return LoginScreen(onLogin: _onLogin, onForgotPassword: _onForgotPassword);
        }
        return MainAppScreen(user: _currentUser!, onLogout: _onLogout);
    }
  }
}
