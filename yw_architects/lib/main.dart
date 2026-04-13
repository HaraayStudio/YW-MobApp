import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
  
  // Setup global error handling
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint("[GlobalError] ${details.exception}");
  };

  try {
    print("[Main] Starting initialization...");
    // Initialize critical services
    await TokenService.init();
    
    // Status bar: transparent + dark icons
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    // Lock to portrait
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    print("[Main] Initialization complete.");
  } catch (e, stack) {
    print("[Main] CRITICAL ERROR during startup: $e");
    print(stack);
  }

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
          builder: (context, child) {
            if (child == null) return const SizedBox.shrink();
            
            // Global error boundary — shows a red screen or error message if build fails
            ErrorWidget.builder = (FlutterErrorDetails details) {
              return Material(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Application Error',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        details.exception.toString(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              );
            };
            
            return child;
          },
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
