import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../widgets/developer_badge.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _nameController        = TextEditingController();
  final _passwordController    = TextEditingController();
  final _confirmController     = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewController  = TextEditingController();

  bool _isFirstTime          = false;
  bool _isLoading            = true;
  bool _showPassword         = false;
  bool _showNewPassword      = false;
  bool _isBiometricAvailable = false;
  bool _showChangePassword   = false;
  String? _errorMessage;
  String? _ownerName;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final hasPassword      = await AuthService.instance.hasMasterPassword();
    final biometricAvail   = await AuthService.instance.isBiometricAvailable();
    final name             = await AuthService.instance.getOwnerName();
    setState(() {
      _isFirstTime          = !hasPassword;
      _isBiometricAvailable = biometricAvail;
      _ownerName            = name;
      _isLoading            = false;
    });

    if (!_isFirstTime && biometricAvail) {
      await Future.delayed(const Duration(milliseconds: 500));
      _authenticateWithBiometrics();
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    final result = await AuthService.instance.authenticateWithBiometrics();
    if (result == BiometricResult.success) {
      _navigateHome();
    } else if (result == BiometricResult.failed) {
      setState(() => _errorMessage = 'فشل التحقق البيومتري. استخدم كلمة السر.');
    }
  }

  void _navigateHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  // ─── Register (first time) ─────────────────────────────────────
  Future<void> _handleRegister() async {
    final name     = _nameController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty) {
      setState(() => _errorMessage = 'يرجى إدخال اسم المستخدم');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'كلمة السر يجب أن تكون 6 أحرف على الأقل');
      return;
    }
    if (password != _confirmController.text) {
      setState(() => _errorMessage = 'كلمتا السر غير متطابقتين');
      return;
    }

    await AuthService.instance.setOwnerName(name);
    await AuthService.instance.setMasterPassword(password);
    if (_isBiometricAvailable) await AuthService.instance.setBiometricEnabled(true);
    _navigateHome();
  }

  // ─── Login ─────────────────────────────────────────────────────
  Future<void> _handleLogin() async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _errorMessage = 'يرجى إدخال كلمة السر');
      return;
    }
    final valid = await AuthService.instance.verifyMasterPassword(password);
    if (valid) {
      _navigateHome();
    } else {
      setState(() => _errorMessage = 'كلمة السر غير صحيحة');
      _passwordController.clear();
    }
  }

  // ─── Change Password ───────────────────────────────────────────
  Future<void> _handleChangePassword() async {
    final old     = _oldPasswordController.text;
    final newPass = _newPasswordController.text;
    final confirm = _confirmNewController.text;

    if (old.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      setState(() => _errorMessage = 'يرجى ملء جميع الحقول');
      return;
    }
    if (newPass.length < 6) {
      setState(() => _errorMessage = 'كلمة السر الجديدة يجب أن تكون 6 أحرف على الأقل');
      return;
    }
    if (newPass != confirm) {
      setState(() => _errorMessage = 'كلمتا السر الجديدة غير متطابقتين');
      return;
    }

    final success = await AuthService.instance.changeMasterPassword(old, newPass);
    if (success) {
      setState(() {
        _showChangePassword = false;
        _errorMessage = null;
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmNewController.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅  تم تغيير كلمة السر بنجاح',
                style: GoogleFonts.tajawal()),
            backgroundColor: Colors.green.shade800,
          ),
        );
      }
    } else {
      setState(() => _errorMessage = 'كلمة السر الحالية غير صحيحة');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFFFFB300))),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0A0A), Color(0xFF111108), Color(0xFF0A0A0A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                    child: _showChangePassword
                        ? _buildChangePasswordForm()
                        : _isFirstTime
                            ? _buildRegisterForm()
                            : _buildLoginForm(),
                  ),
                ),
              ),
              const DeveloperBadge(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Logo ──────────────────────────────────────────────────────
  Widget _buildLogo() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB300), Color(0xFFFF6F00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB300).withOpacity(0.35),
            blurRadius: 30,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Icon(Icons.lock_outline_rounded, color: Colors.black, size: 44),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.5, 0.5))
        .then()
        .shimmer(color: Colors.white24, duration: 1200.ms);
  }

  Widget _buildAppName() => Column(
    children: [
      Text(
        'SecretPass',
        style: GoogleFonts.playfairDisplay(
          color: const Color(0xFFFFB300),
          fontSize: 30,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ).animate().fadeIn(delay: 100.ms),
      const SizedBox(height: 4),
      Text(
        'مدير كلمات السر الآمن',
        style: GoogleFonts.tajawal(color: Colors.white24, fontSize: 12),
      ).animate().fadeIn(delay: 150.ms),
    ],
  );

  // ─── Error Box ─────────────────────────────────────────────────
  Widget _buildError() {
    if (_errorMessage == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_errorMessage!,
                style: GoogleFonts.tajawal(color: Colors.red, fontSize: 13)),
          ),
        ],
      ),
    ).animate().shake();
  }

  // ─── Password Field ────────────────────────────────────────────
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    bool showToggle = true,
    bool isNew = false,
    VoidCallback? onSubmit,
  }) {
    final visible = isNew ? _showNewPassword : _showPassword;
    return TextField(
      controller: controller,
      obscureText: !visible,
      textAlign: TextAlign.right,
      style: const TextStyle(color: Colors.white, letterSpacing: 2),
      decoration: InputDecoration(
        labelText: label,
        hintText: '••••••••',
        prefixIcon: showToggle
            ? IconButton(
                icon: Icon(visible ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white38, size: 20),
                onPressed: () => setState(() {
                  if (isNew) {
                    _showNewPassword = !_showNewPassword;
                  } else {
                    _showPassword = !_showPassword;
                  }
                }),
              )
            : null,
        suffixIcon: const Icon(Icons.lock_outline, color: Color(0xFFFFB300), size: 20),
      ),
      onSubmitted: onSubmit != null ? (_) => onSubmit() : null,
    );
  }

  // ─── Text Field ────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.right,
      keyboardType: keyboardType,
      textCapitalization: capitalization,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFFFFB300)),
      ),
    );
  }

  // ─── Section Label ─────────────────────────────────────────────
  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          text,
          style: GoogleFonts.tajawal(
            color: const Color(0xFFFFB300),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 5, height: 5,
          decoration: const BoxDecoration(
            color: Color(0xFFFFB300), shape: BoxShape.circle,
          ),
        ),
      ],
    ),
  );

  // ══════════════════════════════════════════════════════════════
  // REGISTER FORM (first time)
  // ══════════════════════════════════════════════════════════════
  Widget _buildRegisterForm() {
    return Column(
      children: [
        _buildLogo(),
        const SizedBox(height: 28),
        _buildAppName(),
        const SizedBox(height: 28),

        Text(
          'إنشاء حساب جديد',
          style: GoogleFonts.tajawal(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

        const SizedBox(height: 6),
        Text(
          'أدخل بياناتك لإنشاء خزنتك الآمنة',
          style: GoogleFonts.tajawal(color: Colors.white38, fontSize: 13),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 260.ms),

        const SizedBox(height: 28),

        // ── اسم المستخدم ──
        _sectionLabel('بيانات الحساب'),
        _buildTextField(
          controller: _nameController,
          label: 'اسم المستخدم',
          hint: 'مثال: Abdullah Esh',
          icon: Icons.person_outline,
          keyboardType: TextInputType.name,
          capitalization: TextCapitalization.words,
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.15),

        const SizedBox(height: 14),

        // ── كلمة السر ──
        _buildPasswordField(
          controller: _passwordController,
          label: 'كلمة السر الرئيسية',
        ).animate().fadeIn(delay: 360.ms).slideY(begin: 0.15),

        const SizedBox(height: 14),

        _buildPasswordField(
          controller: _confirmController,
          label: 'تأكيد كلمة السر',
          showToggle: false,
        ).animate().fadeIn(delay: 420.ms).slideY(begin: 0.15),

        _buildError(),

        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _handleRegister,
            child: Text('إنشاء الخزنة', style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ).animate().fadeIn(delay: 480.ms).slideY(begin: 0.2),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // LOGIN FORM
  // ══════════════════════════════════════════════════════════════
  Widget _buildLoginForm() {
    return Column(
      children: [
        _buildLogo(),
        const SizedBox(height: 24),
        _buildAppName(),
        const SizedBox(height: 20),

        // Welcome with owner name
        if (_ownerName != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFB300).withOpacity(0.08),
                  const Color(0xFF1C1A10).withOpacity(0.5),
                ],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFFB300).withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('مرحباً بعودتك 👋',
                          style: GoogleFonts.tajawal(color: Colors.white38, fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(
                        _ownerName!,
                        style: GoogleFonts.playfairDisplay(
                          color: const Color(0xFFFFB300),
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFB300), Color(0xFFFF6F00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFB300).withOpacity(0.3),
                        blurRadius: 10, spreadRadius: 1,
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _ownerName!.isNotEmpty ? _ownerName![0].toUpperCase() : '?',
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 150.ms).slideY(begin: -0.1),
          const SizedBox(height: 20),
        ],

        Text(
          'أدخل كلمة السر الرئيسية للمتابعة',
          style: GoogleFonts.tajawal(color: Colors.white38, fontSize: 13),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 20),

        _buildPasswordField(
          controller: _passwordController,
          label: 'كلمة السر الرئيسية',
          onSubmit: _handleLogin,
        ).animate().fadeIn(delay: 280.ms).slideY(begin: 0.15),

        _buildError(),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _handleLogin,
            child: Text('فتح الخزنة', style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ).animate().fadeIn(delay: 340.ms).slideY(begin: 0.2),

        // Biometric button
        if (_isBiometricAvailable) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _authenticateWithBiometrics,
            icon: const Icon(Icons.face_rounded, color: Color(0xFFFFB300)),
            label: Text(
              'استخدام بصمة الوجه',
              style: GoogleFonts.tajawal(
                color: const Color(0xFFFFB300),
                fontSize: 14, fontWeight: FontWeight.w600,
              ),
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],

        const SizedBox(height: 16),

        // Change password link
        TextButton.icon(
          onPressed: () => setState(() {
            _showChangePassword = true;
            _errorMessage = null;
          }),
          icon: const Icon(Icons.key_rounded, color: Colors.white30, size: 16),
          label: Text(
            'تغيير كلمة السر',
            style: GoogleFonts.tajawal(color: Colors.white30, fontSize: 13),
          ),
        ).animate().fadeIn(delay: 460.ms),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // CHANGE PASSWORD FORM
  // ══════════════════════════════════════════════════════════════
  Widget _buildChangePasswordForm() {
    return Column(
      children: [
        const SizedBox(height: 8),

        // Back button
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: () => setState(() {
              _showChangePassword = false;
              _errorMessage = null;
            }),
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFFFB300), size: 20),
          ),
        ),

        const SizedBox(height: 8),

        // Icon
        Container(
          width: 70, height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFB300).withOpacity(0.1),
            border: Border.all(color: const Color(0xFFFFB300).withOpacity(0.35), width: 1.5),
          ),
          child: const Icon(Icons.lock_reset_rounded, color: Color(0xFFFFB300), size: 34),
        ).animate().scale(duration: 400.ms),

        const SizedBox(height: 20),

        Text(
          'تغيير كلمة السر',
          style: GoogleFonts.playfairDisplay(
            color: const Color(0xFFFFB300), fontSize: 24, fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(delay: 100.ms),

        const SizedBox(height: 6),
        Text(
          'أدخل كلمة السر الحالية ثم الجديدة',
          style: GoogleFonts.tajawal(color: Colors.white38, fontSize: 13),
        ).animate().fadeIn(delay: 150.ms),

        const SizedBox(height: 28),

        _sectionLabel('كلمة السر الحالية'),
        _buildPasswordField(
          controller: _oldPasswordController,
          label: 'كلمة السر الحالية',
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

        const SizedBox(height: 20),

        _sectionLabel('كلمة السر الجديدة'),
        _buildPasswordField(
          controller: _newPasswordController,
          label: 'كلمة السر الجديدة',
          isNew: true,
        ).animate().fadeIn(delay: 260.ms).slideY(begin: 0.1),

        const SizedBox(height: 14),

        _buildPasswordField(
          controller: _confirmNewController,
          label: 'تأكيد كلمة السر الجديدة',
          showToggle: false,
          isNew: true,
          onSubmit: _handleChangePassword,
        ).animate().fadeIn(delay: 310.ms).slideY(begin: 0.1),

        _buildError(),

        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _handleChangePassword,
            child: Text(
              'تغيير كلمة السر',
              style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ).animate().fadeIn(delay: 360.ms).slideY(begin: 0.2),
      ],
    );
  }
}
