import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../login/login_screen.dart';
import '../widgets/appcolors.dart';
import '../core/window_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selected = 0;

  // TODO: replace with data from your API
  final String userName = 'Daniyal Akhtar';
  final int total = 12, completed = 9, pending = 2, critical = 1;

  @override
  void initState() {
    super.initState();
    _resizeWindow();
  }

  Future<void> _resizeWindow() => WindowHelper.dashboardMode();

  void _logout() {
    // TODO: clear stored token
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _Sidebar(
            selected: _selected,
            onSelect: (i) => setState(() => _selected = i),
            onLogout: _logout,
          ),
          Expanded(child: _buildMain()),
        ],
      ),
    );
  }

  Widget _buildMain() {
    final percent = total == 0 ? 0 : (completed / total * 100).round();
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header with truck image
          SizedBox(
            height: 230,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset('assets/images/truck.png',
                      fit: BoxFit.cover, alignment: Alignment.centerRight),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.bg,
                          AppColors.bg.withOpacity(0.92),
                          AppColors.bg.withOpacity(0.0),
                        ],
                        stops: const [0.0, 0.45, 0.8],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 28,
                  top: 50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Welcome Back,',
                          style: TextStyle(fontSize: 24, color: AppColors.navy)),
                      Text('$userName!',
                          style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy)),
                      const SizedBox(height: 6),
                      const Text("Here's what's happening with your fire audit system.",
                          style: TextStyle(color: AppColors.navy)),
                    ],
                  ),
                ),
                Positioned(
                  right: 24,
                  top: 16,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.navy,
                            child: Icon(Icons.person,
                                size: 16, color: Colors.white)),
                        const SizedBox(width: 8),
                        Text(userName,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        const Icon(Icons.keyboard_arrow_down),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              children: [
                // Stat cards
                Row(
                  children: [
                    _StatCard('$total', 'Total Audits', Icons.assignment,
                        AppColors.red, const Color(0xFFFCE4E4)),
                    const SizedBox(width: 16),
                    _StatCard('$completed', 'Completed', Icons.check_box,
                        const Color(0xFF16A34A), const Color(0xFFDDF5E7)),
                    const SizedBox(width: 16),
                    _StatCard('$pending', 'Pending', Icons.schedule,
                        const Color(0xFFF59E0B), const Color(0xFFFDF0D5)),
                    const SizedBox(width: 16),
                    _StatCard('$critical', 'Critical', Icons.priority_high,
                        AppColors.red, const Color(0xFFFCE4E4)),
                  ],
                ),
                const SizedBox(height: 16),
                // Overview + activities
                SizedBox(
                  height: 250,
                  child: Row(
                    children: [
                      Expanded(
                        child: _Panel(
                          title: 'Audit Overview',
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: 160,
                                height: 160,
                                child: CustomPaint(
                                  painter: _DonutPainter(
                                      completed, pending, critical),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('$percent%',
                                            style: const TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.w800)),
                                        const Text('Completed',
                                            style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _Legend(const Color(0xFF16A34A), 'Completed',
                                      completed),
                                  _Legend(const Color(0xFFF59E0B), 'Pending',
                                      pending),
                                  _Legend(AppColors.red, 'Critical', critical),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _Panel(
                          title: 'Recent Activities',
                          trailing: const Text('View All →',
                              style: TextStyle(
                                  color: AppColors.red,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12)),
                          child: Column(
                            children: const [
                              _Activity(Icons.check_circle, Color(0xFF16A34A),
                                  'Audit Completed', 'Main Building - Karachi',
                                  '2 hours ago'),
                              _Activity(Icons.schedule, Color(0xFFF59E0B),
                                  'New Audit Assigned', 'Warehouse Area',
                                  '4 hours ago'),
                              _Activity(Icons.error, AppColors.red,
                                  'Critical Issue Found',
                                  'Fire Extinguisher Missing', '1 day ago'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Reminder + quick actions
                SizedBox(
                  height: 170,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.asset('assets/images/s4.png',
                                    fit: BoxFit.cover,
                                    alignment: Alignment.centerRight),
                              ),
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [
                                      const Color(0xFFFCE4E4),
                                      const Color(0xFFFCE4E4).withOpacity(0.9),
                                      Colors.transparent,
                                    ], stops: const [0, 0.5, 0.85]),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    const Icon(Icons.local_fire_department,
                                        color: AppColors.red, size: 54),
                                    const SizedBox(width: 14),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        const Text('Fire Safety Reminder',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16,
                                                color: AppColors.navy)),
                                        const SizedBox(height: 4),
                                        const Text(
                                            'Regular inspections help prevent\nfire hazards and save lives.',
                                            style: TextStyle(fontSize: 12)),
                                        const SizedBox(height: 12),
                                        ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.red,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(8)),
                                          ),
                                          child: const Text('View Guidelines'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 4,
                        child: _Panel(
                          title: 'Quick Actions',
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const [
                              _QuickAction(Icons.search, 'New Audit'),
                              _QuickAction(Icons.description, 'View Reports'),
                              _QuickAction(Icons.settings, 'Settings'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;
  const _Sidebar(
      {required this.selected, required this.onSelect, required this.onLogout});

  static const items = [
    (Icons.dashboard, 'Dashboard'),
    (Icons.assignment, 'Inspections'),
    (Icons.bar_chart, 'Reports'),
    (Icons.shield, 'Fire Equipment'),
    (Icons.settings, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: const Color(0xFF141B2D),
      child: Stack(
        children: [
          // fireman image at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 280,
            child: ShaderMask(
              shaderCallback: (r) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black],
                stops: [0.0, 0.5],
              ).createShader(r),
              blendMode: BlendMode.dstIn,
              child: Opacity(
                opacity: 0.55,
                child: Image.asset('assets/images/s5.png',
                    fit: BoxFit.cover, alignment: Alignment.topCenter),
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 28),
              const Icon(Icons.local_fire_department,
                  color: AppColors.red, size: 54),
              const SizedBox(height: 6),
              const Text.rich(
                TextSpan(children: [
                  TextSpan(text: 'Fire ', style: TextStyle(color: AppColors.red)),
                  TextSpan(text: 'Audit', style: TextStyle(color: Colors.white)),
                ]),
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 28),
              for (var i = 0; i < items.length; i++)
                _NavItem(
                  icon: items[i].$1,
                  label: items[i].$2,
                  active: i == selected,
                  onTap: () => onSelect(i),
                ),
              _NavItem(
                  icon: Icons.logout,
                  label: 'Logout',
                  active: false,
                  onTap: onLogout),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.all(18),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Be Prepared.',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              fontStyle: FontStyle.italic)),
                      Text('Stay Safe.',
                          style: TextStyle(
                              color: AppColors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavItem(
      {required this.icon,
        required this.label,
        required this.active,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: active ? AppColors.red : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color iconBg, bg;
  const _StatCard(this.value, this.label, this.icon, this.iconBg, this.bg);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: iconBg.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy)),
            Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, color: AppColors.navy)),
          ],
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;
  const _Panel({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy)),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 10),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final int value;
  const _Legend(this.color, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        width: 140,
        child: Row(
          children: [
            CircleAvatar(radius: 5, backgroundColor: color),
            const SizedBox(width: 8),
            Expanded(child: Text(label)),
            Text('$value', style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _Activity extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle, time;
  const _Activity(this.icon, this.color, this.title, this.subtitle, this.time);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.grey)),
              ],
            ),
          ),
          Text(time,
              style: const TextStyle(fontSize: 11, color: AppColors.grey)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  const _QuickAction(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {}, // TODO: navigate
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF0F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.navy, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final int completed, pending, critical;
  _DonutPainter(this.completed, this.pending, this.critical);

  @override
  void paint(Canvas canvas, Size size) {
    final total = completed + pending + critical;
    if (total == 0) return;
    const stroke = 22.0;
    final rect = Rect.fromLTWH(
        stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    final parts = [
      (completed, const Color(0xFF16A34A)),
      (pending, const Color(0xFFF59E0B)),
      (critical, AppColors.red),
    ];
    var start = -math.pi / 2;
    for (final p in parts) {
      final sweep = p.$1 / total * 2 * math.pi;
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..color = p.$2
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.completed != completed ||
          old.pending != pending ||
          old.critical != critical;
}