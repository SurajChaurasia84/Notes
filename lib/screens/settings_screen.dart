import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: const Text('Settings'),
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
                  color: Colors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline, color: Colors.blue),
              ),
              title: const Text('Developer'),
              trailing: const Text(
                'Suraj Chaurasia',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
            const Divider(height: 1, indent: 56),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.code_outlined, color: Colors.green),
              ),
              title: const Text('GitHub Repository'),
              subtitle: const Text(
                'SurajChaurasia84/Notes',
                style: TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                // Future implementation: Launch URL
              },
            ),
          ], cardBg),

          const SizedBox(height: 30),

          // Footer
          Center(
            child: Text(
              'Made with ♥ in Flutter',
              style: TextStyle(
                color: isDark ? Colors.grey[700] : Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
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
