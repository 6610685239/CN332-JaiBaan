import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'edit_profile_page.dart';

class UserSettingsPage extends StatefulWidget {
  final String? token;
  final bool showBackButton;
  const UserSettingsPage({super.key, this.token, this.showBackButton = true});

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  Map<String, dynamic> _userData = {};
  bool _isLoading = true;
  bool _isDark = false;
  bool _notifications = true;

  String get baseUrl {
    if (kIsWeb || Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      return 'http://localhost:3000';
    }
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    final notif = prefs.getBool('notifications') ?? true;

    // Load cached data immediately so UI shows something
    final userJson = prefs.getString('user_data');
    setState(() {
      _userData = userJson != null ? jsonDecode(userJson) : {};
      _isDark = isDark;
      _notifications = notif;
      _isLoading = false;
    });

    // Fetch fresh data from API
    try {
      final token = widget.token ?? prefs.getString('auth_token') ?? '';
      final res = await http.get(
        Uri.parse('$baseUrl/api/user/me'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final fresh = jsonDecode(res.body) as Map<String, dynamic>;
        await prefs.setString('user_data', jsonEncode(fresh));
        if (mounted) {
          setState(() => _userData = fresh);
          userNotifier.value = fresh;
        }
      }
    } catch (_) {}
  }

  File? _localAvatar;
  bool _pickingImage = false;

  Future<void> _pickAndUploadAvatar() async {
    if (_pickingImage) return;
    _pickingImage = true;
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    _pickingImage = false;
    if (picked == null) return;

    // Show local file immediately
    setState(() => _localAvatar = File(picked.path));

    final prefs = await SharedPreferences.getInstance();
    final token = widget.token ?? prefs.getString('auth_token') ?? '';

    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/user/avatar'))
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('avatar', picked.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();
    final data = jsonDecode(body);

    if (response.statusCode == 200 && data['avatarUrl'] != null) {
      _userData['avatarUrl'] = data['avatarUrl'];
      await prefs.setString('user_data', jsonEncode(_userData));
      userNotifier.value = Map<String, dynamic>.from(_userData);
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated'), backgroundColor: Colors.green),
        );
      }
    } else {
      setState(() => _localAvatar = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${data['message'] ?? 'Unknown error'}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _toggleTheme(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', val);
    themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
    setState(() => _isDark = val);
  }

  Future<void> _toggleNotifications(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', val);
    setState(() => _notifications = val);
  }

  bool get _hasName =>
      (_userData['firstName'] ?? '').toString().trim().isNotEmpty;

  String get _displayName {
    final first = _userData['firstName'] ?? '';
    final last = _userData['lastName'] ?? '';
    final full = '$first $last'.trim();
    return full.isNotEmpty ? full : _userData['username'] ?? 'User';
  }

  String get _initials {
    final name = _displayName;
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (name.isNotEmpty) return name[0].toUpperCase();
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final topPad = MediaQuery.of(context).padding.top;

    final body = _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── Fixed header: setting_bg + profile pic + back button ──
                SizedBox(
                  height: 310,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // setting_bg — slightly wider and shifted up
                      Positioned(
                        top: -110, left: -16, right: -16,
                        child: Image.asset(
                          'assets/images/setting_bg.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Back button (hidden when embedded as a tab)
                      if (widget.showBackButton)
                        Positioned(
                          top: topPad + 8,
                          left: 12,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_back_ios_new_rounded,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      // Profile pic + name centered in header
                      Positioned(
                        bottom: 0, left: 0, right: 0,
                        child: _buildProfileSection(),
                      ),
                    ],
                  ),
                ),

                // ── Scrollable cards below header ──
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    child: Column(
                      children: [
                        _buildGroup([
                          _buildTile(
                            icon: Icons.person_outline_rounded,
                            iconColor: const Color(0xFFF05053),
                            title: 'Edit profile information',
                            trailing: _hasName
                                ? null
                                : Container(
                                    width: 8, height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                            onTap: () async {
                              final updated = await Navigator.push<Map<String, dynamic>>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditProfilePage(
                                    userData: _userData,
                                    token: widget.token,
                                  ),
                                ),
                              );
                              if (updated != null) {
                                setState(() => _userData = {..._userData, ...updated});
                              }
                            },
                          ),
                          _buildDivider(),
                          _buildTile(
                            icon: Icons.notifications_outlined,
                            iconColor: const Color(0xFFF05053),
                            title: 'Notifications',
                            trailing: _buildToggle(_notifications, _toggleNotifications),
                          ),
                          _buildDivider(),
                          _buildTile(
                            icon: Icons.language_rounded,
                            iconColor: const Color(0xFFF05053),
                            title: 'Language',
                            trailingText: 'English',
                            onTap: () {},
                          ),
                        ]),
                        const SizedBox(height: 12),
                        _buildGroup([
                          _buildTile(
                            icon: Icons.lock_outline_rounded,
                            iconColor: Colors.grey[600]!,
                            title: 'Security',
                            onTap: () {},
                          ),
                          _buildDivider(),
                          _buildTile(
                            icon: isDarkMode
                                ? Icons.dark_mode_outlined
                                : Icons.light_mode_outlined,
                            iconColor: Colors.grey[600]!,
                            title: 'Theme',
                            trailing: _buildToggle(_isDark, _toggleTheme),
                            trailingText: _isDark ? 'Dark mode' : 'Light mode',
                          ),
                        ]),
                        const SizedBox(height: 12),
                        _buildGroup([
                          _buildTile(
                            icon: Icons.help_outline_rounded,
                            iconColor: Colors.grey[600]!,
                            title: 'Help & Support',
                            onTap: () {},
                          ),
                          _buildDivider(),
                          _buildTile(
                            icon: Icons.headset_mic_outlined,
                            iconColor: Colors.grey[600]!,
                            title: 'Contact us',
                            onTap: () {},
                          ),
                          _buildDivider(),
                          _buildTile(
                            icon: Icons.privacy_tip_outlined,
                            iconColor: Colors.grey[600]!,
                            title: 'Privacy policy',
                            onTap: () {},
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            );

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      body: body,
    );
  }

  Widget _initialsCircle() => Container(
        width: 108, height: 108,
        decoration: const BoxDecoration(color: Color(0xFFF9A082), shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(_initials,
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
      );

  Widget _buildProfileSection() {
    final rawUrl = _userData['avatarUrl'] as String?;
    final avatarUrl = (rawUrl != null && rawUrl.isNotEmpty) ? rawUrl : null;

    Widget avatarWidget;
    if (_localAvatar != null) {
      avatarWidget = ClipOval(
        child: Image.file(_localAvatar!, width: 108, height: 108, fit: BoxFit.cover),
      );
    } else if (avatarUrl != null) {
      avatarWidget = ClipOval(
        child: Image.network(
          avatarUrl,
          width: 108, height: 108,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initialsCircle(),
          loadingBuilder: (_, child, progress) => progress == null ? child : _initialsCircle(),
        ),
      );
    } else {
      avatarWidget = _initialsCircle();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: _pickAndUploadAvatar,
              child: avatarWidget,
            ),
            Positioned(
              bottom: 0, right: 0,
              child: GestureDetector(
                onTap: _pickAndUploadAvatar,
                child: Container(
                  width: 26, height: 26,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4)],
                  ),
                  child: const Icon(Icons.edit_rounded, size: 14, color: Color(0xFFF05053)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _displayName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 2),
        Text(
          [
            if ((_userData['email'] ?? '').isNotEmpty) _userData['email'],
            if ((_userData['phoneNumber'] ?? '').isNotEmpty) _userData['phoneNumber'],
          ].join(' | '),
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: Colors.grey[500]),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildGroup(List<Widget> children) {
    final isDarkMode = themeNotifier.value == ThemeMode.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() => Padding(
        padding: const EdgeInsets.only(left: 56),
        child: Divider(height: 1, color: Colors.grey.withOpacity(0.15)),
      );

  Widget _buildToggle(bool value, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52, height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? const Color(0xFF4CAF50) : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22, height: 22,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? trailingText,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final isDarkMode = themeNotifier.value == ThemeMode.dark;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A), size: 24),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
        ),
      ),
      trailing: trailing ??
          (trailingText != null
              ? Text(trailingText,
                  style: const TextStyle(
                      color: Color(0xFFF05053),
                      fontSize: 13,
                      fontWeight: FontWeight.w500))
              : onTap != null
                  ? Icon(Icons.chevron_right_rounded,
                      color: Colors.grey[400], size: 20)
                  : null),
    );
  }

  void _showEditProfile(BuildContext context) {
    final nameCtrl = TextEditingController(
        text: '${_userData['firstName'] ?? ''} ${_userData['lastName'] ?? ''}'.trim());
    final phoneCtrl = TextEditingController(text: _userData['phoneNumber'] ?? '');
    final emailCtrl = TextEditingController(text: _userData['email'] ?? '');
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    InputDecoration _field(String label, IconData icon) => InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
          prefixIcon: Icon(icon, size: 20, color: Colors.grey[400]),
          filled: true,
          fillColor: const Color(0xFFF7F7F7),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFF05053), width: 1.5),
          ),
        );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                const SizedBox(height: 12),
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                // Header row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text('Edit Profile',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, size: 16, color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameCtrl,
                        decoration: _field('Full Name', Icons.person_outline_rounded),
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _field('Email', Icons.email_outlined),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: _field('Phone Number', Icons.phone_outlined),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF05053),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: saving
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  setSheet(() => saving = true);

                                  final parts = nameCtrl.text.trim().split(' ');
                                  final first = parts[0];
                                  final last = parts.length > 1 ? parts.sublist(1).join(' ') : '';
                                  final prefs = await SharedPreferences.getInstance();
                                  final token = widget.token ?? prefs.getString('auth_token') ?? '';

                                  try {
                                    final res = await http.put(
                                      Uri.parse('$baseUrl/api/user/settings'),
                                      headers: {
                                        'Content-Type': 'application/json',
                                        'Authorization': 'Bearer $token',
                                      },
                                      body: jsonEncode({
                                        'name': first,
                                        'lastName': last,
                                        'email': emailCtrl.text.trim(),
                                        'phone': phoneCtrl.text.trim(),
                                      }),
                                    );

                                    if (res.statusCode == 200) {
                                      final body = jsonDecode(res.body);
                                      final updated = body['user'] as Map<String, dynamic>;
                                      _userData = {..._userData, ...updated};
                                      await prefs.setString('user_data', jsonEncode(_userData));
                                      setState(() {});
                                      if (ctx.mounted) Navigator.pop(ctx);
                                    }
                                  } finally {
                                    setSheet(() => saving = false);
                                  }
                                },
                          child: saving
                              ? const SizedBox(width: 22, height: 22,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Save Changes',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                        ),
                      ),
                      const SizedBox(height: 24),
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
