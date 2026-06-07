import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/healix_app_bar.dart';
import 'settings_page.dart';
import 'login_page.dart';
import 'privacy_policy_page.dart';
import '../store/healix_store.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _phoneController = TextEditingController(text: '0123456789');
  final TextEditingController _addressController = TextEditingController(text: '221B Baker St, Medical District, San Francisco, CA');
  late final TextEditingController _nameController;
  String _selectedCountry = '🇪🇬 Egypt (+20)';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: healixStore.userName.value);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        // Since we are on web, we can use the path or read as bytes
        // For simple display, path is often enough if handled by DecorationImage
        healixStore.profileImageUrl.value = image.path;
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  final List<String> _countries = [
    '🇪🇬 Egypt (+20)',
    '🇸🇦 Saudi Arabia (+966)',
    '🇦🇪 UAE (+971)',
    '🇺🇸 USA (+1)',
    '🇬🇧 UK (+44)',
    '🇰🇼 Kuwait (+965)',
    '🇶🇦 Qatar (+974)',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const HealixAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            _buildProfileHeader(isDark),
            const SizedBox(height: 24),
            _buildPersonalInfoCard(isDark),
            const SizedBox(height: 24),
            _buildAccountSection(isDark),
            const SizedBox(height: 24),
            _buildProTipBox(isDark),
            const SizedBox(height: 24),
            _buildLogoutButton(context, isDark),
            const SizedBox(height: 16),
            Text(
              'App Version 2.4.0',
              style: TextStyle(color: isDark ? Colors.white54 : const Color(0xFF94A3B8), fontSize: 13),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              ValueListenableBuilder<String?>(
                valueListenable: healixStore.profileImageUrl,
                builder: (context, url, _) {
                  return Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).dividerColor, width: 4),
                      image: url != null
                          ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
                          : null,
                    ),
                    child: url == null
                        ? Center(
                            child: Icon(Icons.person_outline, size: 50, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
                          )
                        : null,
                  );
                },
              ),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF00AACD),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.file_upload_outlined, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<String>(
            valueListenable: healixStore.userName,
            builder: (context, name, _) {
              return Text(
                name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_outlined, color: isDark ? Colors.white54 : const Color(0xFF64748B).withOpacity(0.6), size: 14),
              const SizedBox(width: 4),
              Text(
                'Premium Health Member',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : const Color(0xFF64748B).withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_pin_outlined, color: Color(0xFF00AACD), size: 24),
              const SizedBox(width: 12),
              Text(
                'Personal Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF00AACD) : const Color(0xFF006688)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder<String?>(
            valueListenable: healixStore.patientId,
            builder: (context, pId, _) => _infoStaticField('Patient ID', pId ?? 'HX-PENDING', isDark),
          ),
          _infoStaticField('Age', '28 Years', isDark),
          const Text('Full Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
          const SizedBox(height: 8),
          _infoTextField('Name', _nameController, isDark),
          const SizedBox(height: 16),
          _infoStaticField('Email Address', authService.currentUser?.email ?? 'N/A', isDark),
          
          // Editable Phone with Country Selector
          const Text('Phone Number', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white24 : const Color(0xFFE2E8F0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCountry,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                items: _countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCountry = val!),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _infoTextField('Phone', _phoneController, isDark),
          
          const SizedBox(height: 8),
          const Text('Home Address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
          const SizedBox(height: 8),
          _infoTextField('Address', _addressController, isDark, isMultiLine: true),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () {
                healixStore.setUserName(_nameController.text);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully!'),
                    backgroundColor: Color(0xFF00AACD),
                  ),
                );
              },
              icon: const Icon(Icons.save_outlined, size: 22),
              label: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00AACD),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoStaticField(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(value, style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF64748B), fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _infoTextField(String hint, TextEditingController controller, bool isDark, {bool isMultiLine = false}) {
    return TextField(
      controller: controller,
      maxLines: isMultiLine ? 3 : 1,
      style: TextStyle(color: isDark ? Colors.white : const Color(0xFF334155)),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white24 : const Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white24 : const Color(0xFFE2E8F0)),
        ),
      ),
    );
  }

  Widget _buildAccountSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings_outlined, color: Color(0xFF00AACD), size: 24),
              const SizedBox(width: 12),
              Text(
                'Account Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF00AACD) : const Color(0xFF006688)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _accountItem(Icons.settings_outlined, 'Preferences', isDark, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
          }),
          _accountItem(Icons.shield_outlined, 'Privacy Policy', isDark, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()));
          }),
          _accountItem(Icons.lock_outline, 'Security Center', isDark, isLast: true),
        ],
      ),
    );
  }

  Widget _accountItem(IconData icon, String title, bool isDark, {bool isLast = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: isDark ? Colors.white54 : const Color(0xFF64748B), size: 22),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isDark ? Colors.white : const Color(0xFF334155)),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, color: Color(0xFF94A3B8), size: 14),
              ],
            ),
          ),
          if (!isLast) Divider(height: 1, color: isDark ? Colors.white10 : const Color(0xFFF1F5F9)),
        ],
      ),
    );
  }

  Widget _buildProTipBox(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE0F7FA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE0F7FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.lightbulb_outline, color: Color(0xFF00AACD), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pro Tip',
                  style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF00AACD) : const Color(0xFF006688), fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  'Keeping your contact details updated ensures you receive real-time AI alerts for any critical vitals anomalies.',
                  style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF006688), fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: () async {
          await authService.logout();
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          }
        },
        icon: const Icon(Icons.logout_outlined, color: Color(0xFFB91C1C), size: 20),
        label: const Text('Logout', style: TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.bold, fontSize: 16)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: isDark ? Colors.white24 : const Color(0xFFF1F5F9)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: isDark ? Colors.transparent : Colors.white,
        ),
      ),
    );
  }
}
