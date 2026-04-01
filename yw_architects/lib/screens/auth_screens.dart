import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';

class LoginScreen extends StatefulWidget {
  final Function(AppUser) onLogin;
  final VoidCallback onForgotPassword;

  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.onForgotPassword,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController(text: 'ywarchitects@gmail.com');
  final _pwCtrl = TextEditingController(text: 'WhoCares');
  bool _pwVisible = false;
  String? _errorMsg;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  void _doLogin() {
    setState(() => _errorMsg = null);
    final email = _emailCtrl.text.trim();
    final pw = _pwCtrl.text.trim();

    final Map<String, Map<String, dynamic>> creds = {
      'admin@gmail.com': {'pass': 'admin123', 'role': UserRole.admin},
      'srarchitect@gmail.com': {'pass': 'SrArchitect123', 'role': UserRole.senior},
      'jrarchitect@gmail.com': {'pass': 'JrArchitect123', 'role': UserRole.junior},
      'interior@gmail.com': {'pass': 'Interior123', 'role': UserRole.interior},
      'site@gmail.com': {'pass': 'Site123', 'role': UserRole.site},
      'visualizer@gmail.com': {'pass': 'Visualizer123', 'role': UserRole.visualizer},
      'hr@gmail.com': {'pass': 'Hr123', 'role': UserRole.hr},
    };

    if (creds.containsKey(email) && creds[email]!['pass'] == pw) {
      final role = creds[email]!['role'] as UserRole;
      final info = roleMap[role]!;
      widget.onLogin(AppUser(role: role, info: info));
    } else {
      setState(() => _errorMsg = 'Invalid email or password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF9FBEC), Color(0xFFEDEF60), Color(0xFFF3F5E6)],
            stops: [0, 0.5, 1],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Branding
                const SizedBox(height: 16),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'YW',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Architectural\nMastery Begins Here.',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to your workspace',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                // Card
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.outlineVariant.withOpacity(0.15)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.onSurface.withOpacity(0.08),
                        blurRadius: 64,
                        offset: const Offset(0, 32),
                        spreadRadius: -12,
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome back',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Enter your credentials to sign in',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Email
                      _FieldLabel('Email'),
                      const SizedBox(height: 8),
                      _InputField(
                        controller: _emailCtrl,
                        hint: 'admin@gmail.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      // Password
                      _FieldLabel('Password'),
                      const SizedBox(height: 8),
                      _InputField(
                        controller: _pwCtrl,
                        hint: '••••••••',
                        obscureText: !_pwVisible,
                        suffix: IconButton(
                          onPressed: () => setState(() => _pwVisible = !_pwVisible),
                          icon: Icon(
                            _pwVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Demo hint & Error
                      if (_errorMsg != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: const Border(left: BorderSide(color: AppColors.error, width: 2)),
                          ),
                          child: Text(
                            _errorMsg!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: const Border(left: BorderSide(color: AppColors.primaryContainer, width: 2)),
                        ),
                        child: const Text(
                          'Try: admin@gmail.com / admin123',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      GoldGradientButton(
                        text: 'Sign In →',
                        onTap: _doLogin,
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: widget.onForgotPassword,
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    '© 2025 YW Architects. All rights reserved.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurfaceVariant,
        letterSpacing: 1,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final Widget? suffix;
  final TextInputType? keyboardType;

  const _InputField({
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.suffix,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.onSurface,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withOpacity(0.6)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryContainer, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: suffix,
          filled: true,
          fillColor: AppColors.surfaceContainerLow,
        ),
      ),
    );
  }
}

// ==================== FORGOT PASSWORD ====================

class ForgotPasswordScreen extends StatelessWidget {
  final VoidCallback onBack;

  const ForgotPasswordScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final emailCtrl = TextEditingController();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF9FBEC), Color(0xFFEDEF60), Color(0xFFF3F5E6)],
            stops: [0, 0.5, 1],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                  label: const Text(
                    'Back to Login',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.onSurface.withOpacity(0.08),
                        blurRadius: 64,
                        offset: const Offset(0, 32),
                        spreadRadius: -12,
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: goldGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.lock_reset_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter your email to receive a reset link.',
                        style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'WORK EMAIL',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'you@ywarchitects.com',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            filled: true,
                            fillColor: AppColors.surfaceContainerLow,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      GoldGradientButton(
                        text: 'Send Reset Link',
                        onTap: () => showAppToast(context, 'Reset link sent! Check your email.'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
