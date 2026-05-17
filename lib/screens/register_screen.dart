import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passwordCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.registerWithEmail(
          _nameCtrl.text.trim(), _emailCtrl.text.trim(), _passwordCtrl.text);
      if (mounted) { Navigator.pop(context); }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Registration failed: ${e.toString().split(']').last.trim()}'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppColors.primary,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Create Account', style: TextStyle(fontWeight: FontWeight.w800, color: context.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Join VisionGRO', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: context.textPrimary)),
            const SizedBox(height: 4),
            Text('Create your farmer account', style: TextStyle(fontSize: 14, color: context.textSecondary)),
            const SizedBox(height: 28),

            _field('Full Name', 'e.g. Ahmad Razak', _nameCtrl, Icons.person_outline_rounded,
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter your name' : null),
            const SizedBox(height: 14),
            _field('Email', 'e.g. ahmad@email.com', _emailCtrl, Icons.email_outlined,
                type: TextInputType.emailAddress,
                validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null),
            const SizedBox(height: 14),
            _field('Password', 'Min 6 characters', _passwordCtrl, Icons.lock_outline_rounded,
                obscure: _obscure, obscureToggle: () => setState(() => _obscure = !_obscure),
                validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null),
            const SizedBox(height: 14),
            _field('Confirm Password', 'Re-enter password', _confirmCtrl, Icons.lock_outline_rounded,
                obscure: true,
                validator: (v) => v != _passwordCtrl.text ? 'Passwords do not match' : null),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _register,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _field(String label, String hint, TextEditingController ctrl, IconData icon,
      {TextInputType type = TextInputType.text, bool obscure = false,
       VoidCallback? obscureToggle, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary.withValues(alpha: 0.6), size: 20),
        suffixIcon: obscureToggle != null
            ? IconButton(icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20), onPressed: obscureToggle)
            : null,
      ),
    );
  }
}
