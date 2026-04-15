import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/app_models.dart';
import '../widgets/common_widgets.dart';
import '../services/auth_service.dart';

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

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  int _tabIndex = 0; // 0 = Employee, 1 = Client
  bool _isLoading = false;
  String? _errorMsg;

  // Track the previous tab to determine slide direction
  int _prevTabIndex = 0;

  void _switchTab(int index) {
    if (_tabIndex == index) return;
    setState(() {
      _prevTabIndex = _tabIndex;
      _tabIndex = index;
      _errorMsg = null;
    });
  }

  Future<void> _handleEmployeeLogin(String email, String pw) async {
    if (email.isEmpty || pw.isEmpty) {
      setState(() => _errorMsg = 'Please enter your email and password.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final user = await AuthService.loginEmployee(email, pw);
      if (mounted) widget.onLogin(user);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleClientLogin(String email, String pw) async {
    if (email.isEmpty || pw.isEmpty) {
      setState(() => _errorMsg = 'Please enter your email and password.');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final user = await AuthService.loginClient(email, pw);
      if (mounted) widget.onLogin(user);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isClient = _tabIndex == 1;

    return Scaffold(
      backgroundColor: Colors.white,
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 40,
                      ),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.06,
                                      ),
                                      blurRadius: 12,
                                    ),
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
                            ),
                            const SizedBox(height: 32),
                            const Text(
                              'Sign in to your workspace',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Segmented UI Control
                            _SegmentedToggle(
                              selectedIndex: _tabIndex,
                              onChanged: _switchTab,
                            ),
                            const SizedBox(height: 24),

                            // Dynamic Forms Container
                            Container(
                              clipBehavior: Clip.none,
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.outlineVariant.withValues(
                                    alpha: 0.15,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.onSurface.withValues(
                                      alpha: 0.08,
                                    ),
                                    blurRadius: 64,
                                    offset: const Offset(0, 32),
                                    spreadRadius: -12,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Error message if any
                                  if (_errorMsg != null)
                                    AnimatedSize(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        margin: const EdgeInsets.only(
                                          bottom: 20,
                                        ),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: AppColors.errorContainer,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: const Border(
                                            left: BorderSide(
                                              color: AppColors.error,
                                              width: 2,
                                            ),
                                          ),
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
                                    ),

                                  // Form Transition
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 400),
                                    switchInCurve: Curves.easeOutCubic,
                                    switchOutCurve: Curves.easeInCubic,
                                    layoutBuilder:
                                        (currentChild, previousChildren) {
                                          return Stack(
                                            alignment: Alignment.topCenter,
                                            children: <Widget>[
                                              ...previousChildren,
                                              if (currentChild != null)
                                                currentChild,
                                            ],
                                          );
                                        },
                                    transitionBuilder: (child, animation) {
                                      // Determine if the child entering is the new one
                                      final bool isIncoming =
                                          child.key == ValueKey<int>(_tabIndex);

                                      // If tab moved 0 -> 1 (Employee -> Client)
                                      //   Slide In: from Right (+1)
                                      //   Slide Out: to Left (-1)
                                      // If tab moved 1 -> 0 (Client -> Employee)
                                      //   Slide In: from Left (-1)
                                      //   Slide Out: to Right (+1)
                                      final bool forward =
                                          _tabIndex > _prevTabIndex;

                                      if (isIncoming) {
                                        final slideAnim = Tween<Offset>(
                                          begin: Offset(
                                            forward ? 0.3 : -0.3,
                                            0.0,
                                          ),
                                          end: Offset.zero,
                                        ).animate(animation);
                                        return SlideTransition(
                                          position: slideAnim,
                                          child: FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          ),
                                        );
                                      } else {
                                        // Outgoing child scales down and fades
                                        final scaleAnim = Tween<double>(
                                          begin: 0.95,
                                          end: 1.0,
                                        ).animate(animation);
                                        return ScaleTransition(
                                          scale: scaleAnim,
                                          child: FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          ),
                                        );
                                      }
                                    },
                                    child: isClient
                                        ? _ClientLoginForm(
                                            key: const ValueKey<int>(1),
                                            isLoading: _isLoading,
                                            onClientLogin: _handleClientLogin,
                                            onForgotPassword:
                                                widget.onForgotPassword,
                                          )
                                        : _EmployeeLoginForm(
                                            key: const ValueKey<int>(0),
                                            isLoading: _isLoading,
                                            onEmployeeLogin:
                                                _handleEmployeeLogin,
                                            onForgotPassword:
                                                widget.onForgotPassword,
                                          ),
                                  ),
                                ],
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── CUSTOM SEGMENTED TOGGLE (iOS Style) ──────────────────────────────────────

class _SegmentedToggle extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _SegmentedToggle({
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  State<_SegmentedToggle> createState() => _SegmentedToggleState();
}

class _SegmentedToggleState extends State<_SegmentedToggle> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double tabWidth = (width - 8) / 2;

        return GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! > 0) {
              // Swipe Right -> index 1
              widget.onChanged(1);
            } else if (details.primaryVelocity! < 0) {
              // Swipe Left -> index 0
              widget.onChanged(0);
            }
          },
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Stack(
              children: [
                // Animated active pill
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  top: 4,
                  bottom: 4,
                  left: widget.selectedIndex == 0 ? 4 : tabWidth + 4,
                  width: tabWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                // Text layers
                Row(
                  children: [_buildTab(0, 'Employee'), _buildTab(1, 'Client')],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTab(int index, String title) {
    final bool isSelected = widget.selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onChanged(index),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
            ),
            child: Text(title),
          ),
        ),
      ),
    );
  }
}

// ── EMPLOYEE LOGIN FORM ──────────────────────────────────────────────────────

class _EmployeeLoginForm extends StatefulWidget {
  final bool isLoading;
  final Function(String, String) onEmployeeLogin;
  final VoidCallback onForgotPassword;

  const _EmployeeLoginForm({
    super.key,
    required this.isLoading,
    required this.onEmployeeLogin,
    required this.onForgotPassword,
  });

  @override
  State<_EmployeeLoginForm> createState() => _EmployeeLoginFormState();
}

class _EmployeeLoginFormState extends State<_EmployeeLoginForm> {
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _pwVisible = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
          style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 28),
        const _FieldLabel('Email'),
        const SizedBox(height: 8),
        _InputField(
          controller: _emailCtrl,
          hint: 'admin@yw.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        const _FieldLabel('Password'),
        const SizedBox(height: 8),
        _InputField(
          controller: _pwCtrl,
          hint: '••••••••',
          obscureText: !_pwVisible,
          suffix: IconButton(
            onPressed: () => setState(() => _pwVisible = !_pwVisible),
            icon: Icon(
              _pwVisible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.onSurfaceVariant,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 32),

        _AnimatedAuthButton(
          text: 'Sign In →',
          isLoading: widget.isLoading,
          onTap: () => widget.onEmployeeLogin(
            _emailCtrl.text.trim(),
            _pwCtrl.text.trim(),
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }
}

// ── CLIENT LOGIN FORM ────────────────────────────────────────────────────────

class _ClientLoginForm extends StatefulWidget {
  final bool isLoading;
  final Function(String, String) onClientLogin;
  final VoidCallback onForgotPassword;

  const _ClientLoginForm({
    super.key,
    required this.isLoading,
    required this.onClientLogin,
    required this.onForgotPassword,
  });

  @override
  State<_ClientLoginForm> createState() => _ClientLoginFormState();
}

class _ClientLoginFormState extends State<_ClientLoginForm> {
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _pwVisible = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Client Portal',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Track your project progress in real-time',
          style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 28),
        const _FieldLabel('Client Email / ID'),
        const SizedBox(height: 8),
        _InputField(
          controller: _emailCtrl,
          hint: 'client@domain.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        const _FieldLabel('Password'),
        const SizedBox(height: 8),
        _InputField(
          controller: _pwCtrl,
          hint: '••••••••',
          obscureText: !_pwVisible,
          suffix: IconButton(
            onPressed: () => setState(() => _pwVisible = !_pwVisible),
            icon: Icon(
              _pwVisible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.onSurfaceVariant,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 32),

        _AnimatedAuthButton(
          text: 'Access Project →',
          isLoading: widget.isLoading,
          onTap: () =>
              widget.onClientLogin(_emailCtrl.text.trim(), _pwCtrl.text.trim()),
        ),


      ],
    );
  }
}

// ── CUSTOM ANIMATED AUTH BUTTON ──────────────────────────────────────────────
class _AnimatedAuthButton extends StatefulWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onTap;

  const _AnimatedAuthButton({
    required this.text,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_AnimatedAuthButton> createState() => _AnimatedAuthButtonState();
}

class _AnimatedAuthButtonState extends State<_AnimatedAuthButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.isLoading) return;
    widget.onTap(); // ← directly triggers the login handler
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) { if (!widget.isLoading) _animCtrl.forward(); },
      onTapUp:   (_) { if (!widget.isLoading) _animCtrl.reverse(); _handleTap(); },
      onTapCancel: () { if (!widget.isLoading) _animCtrl.reverse(); },
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Opacity(
          opacity: widget.isLoading ? 0.7 : 1.0,
          // Pass null so GoldGradientButton's inner GestureDetector does nothing,
          // leaving all tap handling to the outer GestureDetector above.
          child: GoldGradientButton(
            text: widget.isLoading ? 'Processing...' : widget.text,
            onTap: null,
          ),
        ),
      ),
    );
  }
}

// ── REUSABLE INPUT WIDGETS ───────────────────────────────────────────────────

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

class _InputField extends StatefulWidget {
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
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      // Elevate slightly when focused
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppColors.primaryContainer.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: TextField(
        focusNode: _focusNode,
        controller: widget.controller,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.onSurface,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.primaryContainer,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixIcon: widget.suffix,
          filled: true,
          fillColor: AppColors.surfaceContainerLow,
        ),
      ),
    );
  }
}

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
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
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
                        color: AppColors.onSurface.withValues(alpha: 0.08),
                        blurRadius: 64,
                        offset: const Offset(0, 32),
                        spreadRadius: -12,
                      ),
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
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
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
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const _FieldLabel('WORK EMAIL OR CLIENT ID'),
                      const SizedBox(height: 8),
                      _InputField(
                        controller: emailCtrl,
                        hint: 'you@yw.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 24),
                      GoldGradientButton(
                        text: 'Send Reset Link',
                        onTap: () => showAppToast(
                          context,
                          'Reset link sent! Check your email.',
                        ),
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
