import 'package:flutter/material.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  final TextEditingController _currentPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasSpecialChar = false;
  bool _passwordsMatch = false;

  @override
  void initState() {
    super.initState();
    _newPassController.addListener(_validatePassword);
    _confirmPassController.addListener(_validatePassword);
  }

  void _validatePassword() {
    final text = _newPassController.text;
    setState(() {
      _hasMinLength = text.length >= 8;
      _hasUppercase = text.contains(RegExp(r'[A-Z]'));
      _hasSpecialChar = text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      _passwordsMatch = text.isNotEmpty && text == _confirmPassController.text;
    });
  }

  @override
  void dispose() {
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDark ? Colors.grey.shade400 : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00AACD), size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Change Password',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            _buildLockHeader(isDark, textColor, subTextColor),
            const SizedBox(height: 32),
            _passwordField('CURRENT PASSWORD', _obscureCurrent, () {
              setState(() => _obscureCurrent = !_obscureCurrent);
            }, controller: _currentPassController, isDark: isDark, cardColor: cardColor, subTextColor: subTextColor),
            const SizedBox(height: 16),
            _passwordField('NEW PASSWORD', _obscureNew, () {
              setState(() => _obscureNew = !_obscureNew);
            }, controller: _newPassController, isDark: isDark, cardColor: cardColor, subTextColor: subTextColor),
            const SizedBox(height: 16),
            _passwordField('CONFIRM NEW PASSWORD', _obscureConfirm, () {
              setState(() => _obscureConfirm = !_obscureConfirm);
            }, controller: _confirmPassController, showError: !(_passwordsMatch || _confirmPassController.text.isEmpty), isDark: isDark, cardColor: cardColor, subTextColor: subTextColor),
            const SizedBox(height: 32),
            _buildRequirementsBox(isDark, cardColor, textColor, subTextColor),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_hasMinLength && _hasUppercase && _hasSpecialChar && _passwordsMatch)
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password updated successfully!'),
                            backgroundColor: Color(0xFF0D9488),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    : () {
                        String message = 'Please fix the requirements below';
                        if (_confirmPassController.text.isNotEmpty && !_passwordsMatch) {
                          message = 'Passwords do not match';
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: (_hasMinLength && _hasUppercase && _hasSpecialChar && _passwordsMatch)
                      ? const Color(0xFF00AACD)
                      : const Color(0xFFCBD5E1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.vpn_key_outlined, size: 22),
                    SizedBox(width: 12),
                    Text('Update Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'CANCEL AND GO BACK',
                style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockHeader(bool isDark, Color textColor, Color subTextColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF00AACD),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Color(0x3300AACD), blurRadius: 15, offset: Offset(0, 8)),
            ],
          ),
          child: const Icon(Icons.lock_outline, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 24),
        Text(
          'Secure Your Account',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 12),
        Text(
          'Update your password to keep your medical data protected with Healix AI.',
          textAlign: TextAlign.center,
          style: TextStyle(color: subTextColor, fontSize: 15, height: 1.5),
        ),
      ],
    );
  }

  Widget _passwordField(String label, bool obscure, VoidCallback onToggle, {TextEditingController? controller, bool showError = false, required bool isDark, required Color cardColor, required Color subTextColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF006688), letterSpacing: 0.5),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: showError ? Colors.redAccent : (isDark ? Colors.white12 : const Color(0xFFF1F5F9)), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            onTap: () {
              if (controller != null && controller.text.isNotEmpty) {
                controller.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: controller.text.length,
                );
              }
            },
            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF334155), letterSpacing: 2),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: TextStyle(letterSpacing: 2, color: isDark ? Colors.white24 : const Color(0xFFCBD5E1)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: subTextColor),
                onPressed: onToggle,
              ),
            ),
          ),
        ),
        if (showError)
          const Padding(
            padding: EdgeInsets.only(top: 6, left: 8),
            child: Text('Passwords do not match', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
          ),
      ],
    );
  }

  Widget _buildRequirementsBox(bool isDark, Color cardColor, Color textColor, Color subTextColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: const Color(0xFF006688).withOpacity(0.8), size: 20),
              const SizedBox(width: 10),
              Text(
                'Security Requirements',
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _requirementRow('Minimum 8 characters long', _hasMinLength, subTextColor),
          _requirementRow('At least one uppercase letter', _hasUppercase, subTextColor),
          _requirementRow('One special character (!@#\$%^&*)', _hasSpecialChar, subTextColor),
        ],
      ),
    );
  }

  Widget _requirementRow(String text, bool isMet, Color subTextColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(isMet ? Icons.check_circle_outline : Icons.circle_outlined, color: isMet ? const Color(0xFF00AACD) : const Color(0xFF94A3B8), size: 18),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: isMet ? const Color(0xFF00AACD) : subTextColor,
              fontSize: 14,
              fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
