import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/auth_helper.dart';

class AuthWrapper extends StatefulWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  bool _isLocked = false;
  bool _isLoading = true;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLockStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // When app goes to background, lock it again if enabled
      _lockIfEnabled();
    }
  }

  Future<void> _checkLockStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLockEnabled = prefs.getBool('is_app_lock_enabled') ?? false;

    if (mounted) {
      setState(() {
        _isLocked = isLockEnabled;
        _isLoading = false;
      });

      if (isLockEnabled) {
        _triggerAuth();
      }
    }
  }

  Future<void> _lockIfEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final isLockEnabled = prefs.getBool('is_app_lock_enabled') ?? false;
    if (isLockEnabled && mounted) {
      setState(() {
        _isLocked = true;
      });
    }
  }

  Future<void> _triggerAuth() async {
    setState(() {
      _isAuthenticating = true;
    });

    final success = await AuthHelper.authenticate();

    if (mounted) {
      setState(() {
        _isAuthenticating = false;
        if (success) {
          _isLocked = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF5B041)),
          ),
        ),
      );
    }

    if (_isLocked) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF6F6F6),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5B041).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    size: 64,
                    color: Color(0xFFF5B041),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Note Karo is Locked',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Unlock with your fingerprint to continue',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: _isAuthenticating ? null : _triggerAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5B041),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  icon: const Icon(Icons.fingerprint_rounded),
                  label: Text(_isAuthenticating ? 'Authenticating...' : 'Unlock Now'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}
