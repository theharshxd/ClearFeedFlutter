import 'package:flutter/material.dart';
import '../services/block_counter.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<String, int> _appBlocks = {};
  int _totalToday = 0;

  final List<Map<String, dynamic>> _apps = [
    {'name': 'YouTube', 'icon': Icons.play_circle_fill, 'sub': 'Shorts blocked'},
    {'name': 'Instagram', 'icon': Icons.camera_alt, 'sub': 'Reels blocked'},
    {'name': 'TikTok', 'icon': Icons.music_note, 'sub': 'Video feed blocked'},
    {'name': 'Facebook', 'icon': Icons.facebook, 'sub': 'Reels blocked'},
    {'name': 'Snapchat', 'icon': Icons.chat_bubble, 'sub': 'Spotlight blocked'},
    {'name': 'X', 'icon': Icons.close, 'sub': 'Video feed blocked'},
    {'name': 'Reddit', 'icon': Icons.reddit, 'sub': 'Video feed blocked'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final blocks = await BlockCounter.getAllAppCounts();
    final total = await BlockCounter.getTodayCount();
    setState(() {
      _appBlocks = blocks;
      _totalToday = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxBlocks = _appBlocks.values.isEmpty
        ? 1
        : _appBlocks.values.reduce((a, b) => a > b ? a : b);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Usage Analytics',
              style: TextStyle(
                  color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Daily video feed interruptions',
              style: TextStyle(color: Color(0xFF555555), fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Total blocked card
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
                    'Total Blocked Today',
                    style: TextStyle(color: Color(0xFF888888), fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$_totalToday',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -2,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.shield_outlined,
                          size: 13, color: Color(0xFF888888)),
                      const SizedBox(width: 6),
                      const Text(
                        'System active & monitoring',
                        style: TextStyle(color: Color(0xFF888888), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'App Breakdown',
              style: TextStyle(
                  color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // App list
            ..._apps.map((app) {
              final name = app['name'] as String;
              final count = _appBlocks[name] ?? 0;
              final pct = maxBlocks > 0 ? count / maxBlocks : 0.0;
              return _buildAppBlockRow(
                  name, app['icon'] as IconData, app['sub'] as String, count, pct);
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBlockRow(
      String name, IconData icon, String sub, int count, double pct) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF222222),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(sub,
                        style:
                            const TextStyle(color: Color(0xFF555555), fontSize: 12)),
                  ],
                ),
              ),
              Text(
                '$count blocks',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: pct.toDouble(),
              backgroundColor: const Color(0xFF222222),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }
}
