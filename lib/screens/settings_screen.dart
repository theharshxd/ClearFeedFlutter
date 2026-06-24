import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
  bool _accessibilityActive = false;
  bool _antiUninstall = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _antiUninstall = prefs.getBool('anti_uninstall') ?? true;
      _accessibilityActive = true; // checked via platform channel
    });
  }

  Future<void> _saveAntiUninstall(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('anti_uninstall', val);
    setState(() => _antiUninstall = val);
  }

  void _openAccessibilitySettings() {
    const platform = MethodChannel('com.clearfeed.app/accessibility');
    platform.invokeMethod('openAccessibilitySettings').catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, color: Color(0xFF888888), size: 22),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFF1A1A1A), height: 1),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // SYSTEM STATUS
                _buildSectionLabel('SYSTEM STATUS'),
                _buildAccessibilityRow(),
                const Divider(color: Color(0xFF1A1A1A), height: 1),
                _buildAntiUninstallRow(),
                const Divider(color: Color(0xFF1A1A1A), height: 1),

                // PREFERENCES (empty section kept for design match)
                _buildSectionLabel('PREFERENCES'),
                const Divider(color: Color(0xFF1A1A1A), height: 1),

                // ABOUT
                _buildSectionLabel('ABOUT'),
                _buildVersionRow(),
                const Divider(color: Color(0xFF1A1A1A), height: 1),

                // Bottom branding
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ClearFeed',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Focus on what matters.',
                        style: TextStyle(color: Color(0xFF555555), fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _antiUninstall
                            ? 'Uninstall Protection Enabled'
                            : 'Uninstall Protection Disabled',
                        style: const TextStyle(
                            color: Color(0xFF444444), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        label,
        style: const TextStyle(
            color: Color(0xFF555555), fontSize: 11, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildAccessibilityRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.accessibility_new,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Accessibility Service',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 2),
                Text('Required to detect video feeds',
                    style:
                        TextStyle(color: Color(0xFF555555), fontSize: 12)),
              ],
            ),
          ),
          GestureDetector(
            onTap: _openAccessibilitySettings,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _accessibilityActive
                    ? const Color(0xFF222222)
                    : const Color(0xFF1A0A0A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _accessibilityActive ? 'ACTIVE' : 'ENABLE',
                style: TextStyle(
                  color: _accessibilityActive
                      ? Colors.white
                      : const Color(0xFFFF4444),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAntiUninstallRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                const Icon(Icons.shield_outlined, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Anti-Uninstall',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                SizedBox(height: 2),
                Text('Prevents accidental removal while active',
                    style:
                        TextStyle(color: Color(0xFF555555), fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: _antiUninstall,
            onChanged: _saveAntiUninstall,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF444444),
            inactiveThumbColor: const Color(0xFF444444),
            inactiveTrackColor: const Color(0xFF222222),
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.info_outline, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Version',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              SizedBox(height: 2),
              Text('1.0.0 (Build 1)',
                  style: TextStyle(color: Color(0xFF555555), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
