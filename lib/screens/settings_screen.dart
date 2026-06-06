import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/auth_helper.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isAppLockEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAppLockEnabled = prefs.getBool('is_app_lock_enabled') ?? false;
    });
  }

  Future<void> _toggleAppLock(bool value) async {
    final success = await AuthHelper.authenticate();
    if (success) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_app_lock_enabled', value);
      setState(() {
        _isAppLockEnabled = value;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fingerprint authentication failed/cancelled'),
          ),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Section: Appearance
          _buildSectionHeader('Appearance'),
          _buildSettingsGroup([
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: Text(isDark ? 'Dark theme enabled' : 'Light theme enabled'),
              secondary: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: isDark ? const Color(0xFFF5B041) : Colors.grey[600],
              ),
              value: isDark,
              activeThumbColor: const Color(0xFFF5B041),
              onChanged: (value) {
                widget.onThemeChanged(value);
                setState(() {});
              },
            ),
          ], cardBg),

          const SizedBox(height: 20),

          // Section: Security
          _buildSectionHeader('Security'),
          _buildSettingsGroup([
            SwitchListTile(
              title: const Text('App Lock'),
              subtitle: const Text('Lock app with fingerprint biometrics'),
              secondary: Icon(
                Icons.fingerprint,
                color: _isAppLockEnabled ? const Color(0xFFF5B041) : Colors.grey[600],
              ),
              value: _isAppLockEnabled,
              activeThumbColor: const Color(0xFFF5B041),
              onChanged: _toggleAppLock,
            ),
          ], cardBg),

          const SizedBox(height: 20),

          // Section: About
          _buildSectionHeader('About'),
          _buildSettingsGroup([
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5B041).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.info_outline, color: Color(0xFFF5B041)),
              ),
              title: const Text('Version'),
              trailing: const Text(
                '1.0.0',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
            const Divider(height: 1, indent: 56),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5B041).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.privacy_tip_outlined, color: Color(0xFFF5B041)),
              ),
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: _launchPrivacyPolicy,
            ),
            const Divider(height: 1, indent: 56),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5B041).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.help_outline, color: Color(0xFFF5B041)),
              ),
              title: const Text('Help & Support'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: _showHelpSupportDialog,
            ),
          ], cardBg),

          const SizedBox(height: 30),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 24.0, top: 12.0),
        child: Text(
          '© 2026 Notes & Tasks. All rights reserved.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? Colors.grey[700] : Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Future<void> _launchPrivacyPolicy() async {
    final url = Uri.parse('https://surajchaurasia84.github.io/Notes/');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open the privacy policy link.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening link: $e')),
        );
      }
    }
  }


  void _showHelpSupportDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Help & Support', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Need assistance? Here is how to use the app:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                '• Adding items: Click the floating "+" button to add a new note or task.\n'
                '• Editing notes: Simply click on any note card to modify it.\n'
                '• Completing tasks: Click the checkbox next to any task.\n'
                '• Deleting items: Long press on any card and confirm deletion.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFFF5B041),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children, Color cardBg) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.isDarkMode ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }
}
