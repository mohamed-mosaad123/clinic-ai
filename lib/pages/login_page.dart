import 'package:flutter/material.dart';
import 'home_page.dart';
import 'signup_page.dart';
import 'doctor_home_page.dart';
import 'forgot_password_page.dart';
import '../store/healix_store.dart';
import '../utils/page_transitions.dart';
import '../widgets/healix_background.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  final String? initialRole;
  const LoginPage({super.key, this.initialRole});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? _selectedRole;
  String? _hoveredRole;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialRole != null) {
      _selectedRole = widget.initialRole;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your role (Patient or Doctor)'), backgroundColor: Colors.orange),
      );
      return;
    }
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email and password'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole!,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      final user = result.user!;
      healixStore.setUserName(user.fullName.isNotEmpty ? user.fullName : _emailController.text.split('@').first);
      if (user.role.toLowerCase() == 'doctor') {
        Navigator.pushReplacement(context, SlideRightRoute(page: DoctorHomePage(username: user.fullName)));
      } else {
        Navigator.pushReplacement(context, SlideRightRoute(page: HomePage(username: user.fullName)));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.errorMessage ?? 'Login failed'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: HealixBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 80.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/logo_full.jpeg',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 60),
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10),
                const Opacity(
                  opacity: 0.6,
                  child: Text(
                    'Sign in to access your health data.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: MouseRegion(
                        onEnter: (_) => setState(() => _hoveredRole = 'patient'),
                        onExit: (_) => setState(() => _hoveredRole = null),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedRole = 'patient'),
                          child: AnimatedScale(
                            scale: _selectedRole == 'patient' ? 1.05 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutBack,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: _selectedRole == 'patient'
                                    ? const Color(0xFF0088CC).withOpacity(0.1)
                                    : (_hoveredRole == 'patient' ? (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100]) : Colors.transparent),
                                border: Border.all(
                                  color: _selectedRole == 'patient'
                                      ? const Color(0xFF0088CC)
                                      : (_hoveredRole == 'patient' ? const Color(0xFF0088CC).withOpacity(0.5) : (isDark ? Colors.white24 : const Color(0xFFE2E8F0))),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'Patient',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _selectedRole == 'patient' ? const Color(0xFF0088CC) : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MouseRegion(
                        onEnter: (_) => setState(() => _hoveredRole = 'doctor'),
                        onExit: (_) => setState(() => _hoveredRole = null),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedRole = 'doctor'),
                          child: AnimatedScale(
                            scale: _selectedRole == 'doctor' ? 1.05 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutBack,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: _selectedRole == 'doctor'
                                    ? const Color(0xFF0088CC).withOpacity(0.1)
                                    : (_hoveredRole == 'doctor' ? (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100]) : Colors.transparent),
                                border: Border.all(
                                  color: _selectedRole == 'doctor'
                                      ? const Color(0xFF0088CC)
                                      : (_hoveredRole == 'doctor' ? const Color(0xFF0088CC).withOpacity(0.5) : (isDark ? Colors.white24 : const Color(0xFFE2E8F0))),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'Doctor',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _selectedRole == 'doctor' ? const Color(0xFF0088CC) : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                _buildTextField(Icons.email_outlined, 'Email Address', 'Enter your email', controller: _emailController),
                const SizedBox(height: 20),
                _buildTextField(
                  Icons.lock_outline,
                  'Password',
                  '••••••••',
                  obscure: _obscurePassword,
                  controller: _passwordController,
                  isPassword: true,
                  onToggleObscure: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        SlideRightRoute(
                          page: ForgotPasswordPage(role: _selectedRole),
                        ),
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Color(0xFF0088CC), fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                 SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00AACD),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text('Sign In', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Don\'t have an account? ',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                    TextButton(
                      onPressed: () {
                        if (_selectedRole == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select a role (Patient or Doctor) before signing up'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }
                        Navigator.push(context, SlideRightRoute(page: SignUpPage(role: _selectedRole!)));
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF0088CC),
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    IconData icon,
    String label,
    String hint, {
    bool obscure = false,
    TextEditingController? controller,
    bool isPassword = false,
    VoidCallback? onToggleObscure,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final fillColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? Colors.white24 : const Color(0xFFE2E8F0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A)),
          onTap: () {
            if (isPassword && controller != null && controller.text.isNotEmpty) {
              controller.selection = TextSelection(
                baseOffset: 0,
                extentOffset: controller.text.length,
              );
            }
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? Colors.white38 : const Color(0xFF94A3B8)),
            prefixIcon: Icon(icon, color: isDark ? Colors.white38 : const Color(0xFF94A3B8)),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                    ),
                    onPressed: onToggleObscure,
                  )
                : null,
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00AACD)),
            ),
          ),
        ),
      ],
    );
  }
}
