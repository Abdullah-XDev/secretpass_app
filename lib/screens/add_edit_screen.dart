import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/password_entry.dart';
import '../services/database_service.dart';
import '../widgets/developer_badge.dart';

class AddEditScreen extends StatefulWidget {
  final PasswordEntry? entry;
  const AddEditScreen({super.key, this.entry});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _accountNameCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _websiteCtrl;
  late final TextEditingController _notesCtrl;

  bool _showPassword = false;
  bool _isSaving = false;

  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _usernameCtrl = TextEditingController(text: e?.username ?? '');
    _accountNameCtrl = TextEditingController(text: e?.accountName ?? '');
    _passwordCtrl = TextEditingController(text: e?.password ?? '');
    _websiteCtrl = TextEditingController(text: e?.website ?? '');
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _accountNameCtrl.dispose();
    _passwordCtrl.dispose();
    _websiteCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();
      final entry = _isEditing
          ? widget.entry!.copyWith(
              username: _usernameCtrl.text.trim(),
              accountName: _accountNameCtrl.text.trim(),
              password: _passwordCtrl.text,
              website: _websiteCtrl.text.trim().isEmpty ? null : _websiteCtrl.text.trim(),
              notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
            )
          : PasswordEntry(
              id: const Uuid().v4(),
              username: _usernameCtrl.text.trim(),
              accountName: _accountNameCtrl.text.trim(),
              password: _passwordCtrl.text,
              website: _websiteCtrl.text.trim().isEmpty ? null : _websiteCtrl.text.trim(),
              notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
              createdAt: now,
              updatedAt: now,
            );

      if (_isEditing) {
        await DatabaseService.instance.updateEntry(entry);
      } else {
        await DatabaseService.instance.insertEntry(entry);
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'تعديل الحساب' : 'إضافة حساب جديد'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SectionLabel(label: 'بيانات الحساب'),
            const SizedBox(height: 12),

            _buildField(
              controller: _accountNameCtrl,
              label: 'اسم الحساب',
              hint: 'مثال: Google، Gmail، Twitter',
              icon: Icons.label_outline,
              validator: (v) => (v?.isEmpty ?? true) ? 'مطلوب' : null,
            ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1),
            const SizedBox(height: 14),

            _buildField(
              controller: _usernameCtrl,
              label: 'الإيميل أو اسم المستخدم',
              hint: 'user@example.com',
              icon: Icons.person_outline,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v?.isEmpty ?? true) ? 'مطلوب' : null,
            ).animate().fadeIn(delay: 150.ms).slideX(begin: 0.1),
            const SizedBox(height: 14),

            // Password field
            TextFormField(
              controller: _passwordCtrl,
              obscureText: !_showPassword,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white, letterSpacing: 2),
              validator: (v) => (v?.isEmpty ?? true) ? 'مطلوب' : null,
              decoration: InputDecoration(
                labelText: 'كلمة السر',
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFFFB300)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white38,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                ),
              ),
            ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),

            const SizedBox(height: 24),
            _SectionLabel(label: 'معلومات إضافية (اختياري)'),
            const SizedBox(height: 12),

            _buildField(
              controller: _websiteCtrl,
              label: 'الموقع الإلكتروني',
              hint: 'https://example.com',
              icon: Icons.language,
              keyboardType: TextInputType.url,
            ).animate().fadeIn(delay: 250.ms).slideX(begin: 0.1),
            const SizedBox(height: 14),

            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'ملاحظات',
                hintText: 'أي معلومات إضافية...',
                prefixIcon: Icon(Icons.note_outlined, color: Color(0xFFFFB300)),
                alignLabelWithHint: true,
              ),
            ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(_isEditing ? 'حفظ التغييرات' : 'إضافة الحساب'),
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

            const SizedBox(height: 40),
          ],
        ),
      ),
          ),
          const DeveloperBadge(),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.right,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFFFFB300)),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          label,
          style: GoogleFonts.tajawal(
            color: const Color(0xFFFFB300),
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 8),
        Container(width: 4, height: 4, decoration: const BoxDecoration(
          color: Color(0xFFFFB300),
          shape: BoxShape.circle,
        )),
      ],
    );
  }
}
