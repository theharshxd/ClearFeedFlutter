import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/block_counter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _isActive = false;
  int _blockedToday = 0;

  final Map<String, bool> _appToggles = {
    'YouTube': true,
    'Instagram': true,
    'TikTok': true,
    'Facebook': true,
    'Snapchat': true,
    'X': true,
    'Reddit': true,
  };

  final Map<String, String> _appSubtitles = {
    'YouTube': 'Shorts blocked',
    'Instagram': 'Reels blocked',
    'TikTok': 'Full video feed blocked',
    'Facebook': 'Reels blocked',
    'Snapchat': 'Spotlight blocked',
    'X': 'Video feed blocked',
    'Reddit': 'Video feed blocked',
  };

  final Map<String, IconData> _appIcons = {
    'YouTube': Icons.play_circle_fill,
    'Instagram': Icons.camera_alt,
    'TikTok': Icons.music_note,
    'Facebook': Icons.facebook,
    'Snapchat': Icons.chat_bubble,
    'X': Icons.close,
    'Reddit': Icons.reddit,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final count = await BlockCounter.getTodayCount();
    final active = _checkAccessibilityEnabled();
    setState(() {
      _blockedToday = count;
      _isActive = active;
      for (final key in _appToggles.keys) {
        _appToggles[key] = prefs.getBool('toggle_$key') ?? true;
      }
    });
  }

  bool _checkAccessibilityEnabled() {
    // Checked via platform channel in real app
    // For now returns stored preference
    return true;
  }

  Future<void> _saveToggle(String app, bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('toggle_$app', val);
  }

  void _openAccessibilitySettings() {
    const platform = MethodChannel('com.clearfeed.app/accessibility');
    platform.invokeMethod('openAccessibilitySettings').catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildHeader(),
            const SizedBox(height: 24),
            _buildBlockedCard(),
            const SizedBox(height: 28),
            _buildAppBlocksSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ClearFeed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _isActive ? const Color(0xFF44CC77) : const Color(0xFFFF4444),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _isActive ? 'Protection Active' : 'Tap to Enable',
                  style: TextStyle(
                    color: _isActive ? const Color(0xFF44CC77) : const Color(0xFFFF4444),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
        GestureDetector(
          onTap: _openAccessibilitySettings,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.settings_outlined, color: Color(0xFF888888), size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildBlockedCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Blocked Today',
          style: TextStyle(color: Color(0xFF888888), fontSize: 13),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$_blockedToday',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.bold,
                height: 1.0,
                letterSpacing: -2,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'times',
              style: TextStyle(color: Color(0xFF555555), fontSize: 18),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppBlocksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'App Blocks',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'Configure',
                style: TextStyle(color: Color(0xFF888888), fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._appToggles.keys.map((app) => _buildAppRow(app)),
      ],
    );
  }

  Widget _buildAppRow(String app) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF222222),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_appIcons[app], color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(app,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(_appSubtitles[app]!,
                    style: const TextStyle(color: Color(0xFF555555), fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: _appToggles[app]!,
            onChanged: (val) {
              setState(() => _appToggles[app] = val);
              _saveToggle(app, val);
            },
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF444444),
            inactiveThumbColor: const Color(0xFF444444),
            inactiveTrackColor: const Color(0xFF222222),
            trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }
}
