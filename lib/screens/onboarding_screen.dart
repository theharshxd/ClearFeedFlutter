import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_dashboard.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;

  void _next() {
    if (_step < 2) {
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainDashboard()),
    );
  }

  void _openAccessibilitySettings() {
    const platform = MethodChannel('com.clearfeed.app/accessibility');
    platform.invokeMethod('openAccessibilitySettings').catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _step == 0
            ? _buildStep1()
            : _step == 1
                ? _buildStep2()
                : _buildStep3(),
      ),
    );
  }

  // ── Step 1: Welcome ──
  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 64),
          // App icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.filter_alt, color: Colors.black, size: 36),
          ),
          const SizedBox(height: 20),
          const Text(
            'ClearFeed',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Silently blocks video feed scrolling',
            style: TextStyle(
              color: Color(0xFF888888),
              fontSize: 16,
            ),
          ),
          const Spacer(),
          // Step dots
          _buildDots(0),
          const SizedBox(height: 20),
          _buildPrimaryButton('Get Started', _next),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Step 1 of 3',
              style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Step 2: System Access ──
  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          // Back + dots
          Row(
            children: [
              GestureDetector(
                onTap: _back,
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
              ),
              const Spacer(),
              _buildDots(1),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'System Access',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'ClearFeed needs to monitor your screen to detect when you\'re swiping through video feeds.',
            style: TextStyle(color: Color(0xFF888888), fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 32),
          _buildInstructionCard(Icons.settings, '1. Open Settings',
              'Tap the button below to access your system Accessibility settings.'),
          const SizedBox(height: 12),
          _buildInstructionCard(Icons.search, '2. Find ClearFeed',
              'Locate ClearFeed in the list of available services.'),
          const SizedBox(height: 12),
          _buildInstructionCard(Icons.toggle_on, '3. Enable Service',
              'Turn the switch ON and grant the required permissions.'),
          const Spacer(),
          _buildPrimaryButton('Open Accessibility Settings', _openAccessibilitySettings),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_outlined, size: 14, color: Colors.white.withOpacity(0.3)),
              const SizedBox(width: 6),
              Text(
                'Your data never leaves this device',
                style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Step 3: Everything Ready ──
  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Row(
            children: [
              GestureDetector(
                onTap: _back,
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
              ),
              const Spacer(),
              _buildDots(2),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 40),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.done_all, color: Colors.black, size: 34),
            ),
          ),
          const SizedBox(height: 28),
          const Center(
            child: Text(
              'Everything is ready',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'ClearFeed is now monitoring your screen. It will silently redirect you if you start swiping through video feeds.',
              style: TextStyle(color: Color(0xFF888888), fontSize: 14, height: 1.6),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CONFIGURATION SUMMARY',
                  style: TextStyle(color: Color(0xFF555555), fontSize: 11, letterSpacing: 1.2),
                ),
                const Divider(color: Color(0xFF222222), height: 24),
                _buildSummaryRow('Accessibility Service Active'),
                const SizedBox(height: 14),
                _buildSummaryRow('App Detection Enabled'),
                const SizedBox(height: 14),
                _buildSummaryRow('Auto-redirect Active'),
              ],
            ),
          ),
          const Spacer(),
          _buildPrimaryButton('Go to Dashboard', _finish),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_outlined, size: 14, color: Colors.white.withOpacity(0.3)),
              const SizedBox(width: 6),
              Text(
                'Runs locally on your device. No data leaves your phone.',
                style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String text) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: Color(0xFF444444),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 14),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }

  Widget _buildInstructionCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFF222222),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(color: Color(0xFF888888), fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDots(int active) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: i == active ? 24 : 8,
          height: 4,
          decoration: BoxDecoration(
            color: i == active ? Colors.white : const Color(0xFF333333),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildPrimaryButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
