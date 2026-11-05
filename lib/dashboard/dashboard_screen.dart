import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/api_clinet.dart';
import '../core/format.dart';
import '../core/session.dart';
import '../core/window_helper.dart';
import '../equipment/equipment_screen.dart';
import '../login/login_screen.dart';
import '../models/extinguisher.dart';
import '../reports/reports_screen.dart';
import '../services/auth_service.dart';
import '../services/extinguisher_service.dart';
import '../widgets/appcolors.dart';
import '../widgets/error_banner.dart';
import '../widgets/status_chip.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selected = 0;

  List<Extinguisher> _items = [];
  bool _loading = true;
  String? _error;

  String get userName {
    final n = Session.instance.user?.name ?? '';
    return n.isEmpty ? 'User' : n;
  }

  String get userRole => Session.instance.user?.roleLabel ?? '';

  @override
  void initState() {
    super.initState();
    WindowHelper.dashboardMode();
    _load();
  }

  /// Fetches the extinguisher list. A 401 here means the session could not be
  /// refreshed, so we send the user back to the login screen.
  Future<void> _load() async {
    try {
      final list = await ExtinguisherService.instance.list();
      if (!mounted) return;
      setState(() {
        _items = list;
        _loading = false;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.isAuthError) {
        await _logout();
        return;
      }
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load data. Please try again.';
      });
    }
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await _load();
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    await WindowHelper.authMode();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _showGuidelines() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Fire Safety Guidelines'),
        content: const Text(
          '• Inspect extinguishers monthly\n'
              '• Check the pressure gauge is in the green zone\n'
              '• Make sure the pin and seal are intact\n'
              '• Never block exits or equipment\n'
              '• Replace or refill expired units immediately',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
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
          Expanded(child: _content()),
        ],
      ),
    );
  }

  Widget _content() {
    switch (_selected) {
      case 0:
        return _home();
      case 2:
        return const ReportsScreen();
      case 3:
        return EquipmentScreen(
          items: _items,
          loading: _loading,
          error: _error,
          onRefresh: _refresh,
          onUnauthorized: _logout,
        );
      default:
        return _ComingSoon(title: _Sidebar.items[_selected].$2);
    }
  }

  Widget _home() {
    final total = _items.length;
    final valid =
        _items.where((e) => e.status == EquipStatus.valid).length;
    final expiring =
        _items.where((e) => e.status == EquipStatus.expiringSoon).length;
    final expired =
        _items.where((e) => e.status == EquipStatus.expired).length;
    final percent = total == 0 ? 0 : (valid / total * 100).round();
    final recent = _items.take(3).toList();

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
                      const Text(
                          "Here's what's happening with your fire audit system.",
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(userName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 13)),
                            if (userRole.isNotEmpty)
                              Text(userRole,
                                  style: const TextStyle(
                                      fontSize: 11, color: AppColors.grey)),
                          ],
                        ),
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
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: LinearProgressIndicator(
                        minHeight: 3, color: AppColors.red),
                  ),
                if (_error != null)
                  ErrorBanner(message: _error!, onRetry: _refresh),
                // Stat cards
                Row(
                  children: [
                    _StatCard('$total', 'Total Batches', Icons.assignment,
                        AppColors.red, const Color(0xFFFCE4E4)),
                    const SizedBox(width: 16),
                    _StatCard('$valid', 'Valid', Icons.check_box,
                        const Color(0xFF16A34A), const Color(0xFFDDF5E7)),
                    const SizedBox(width: 16),
                    _StatCard('$expiring', 'Expiring Soon', Icons.schedule,
                        const Color(0xFFF59E0B), const Color(0xFFFDF0D5)),
                    const SizedBox(width: 16),
                    _StatCard('$expired', 'Expired', Icons.priority_high,
                        AppColors.red, const Color(0xFFFCE4E4)),
                  ],
                ),
                const SizedBox(height: 16),
                // Overview + recent batches
                SizedBox(
                  height: 250,
                  child: Row(
                    children: [
                      Expanded(
                        child: _Panel(
                          title: 'Equipment Overview',
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: 160,
                                height: 160,
                                child: CustomPaint(
                                  painter:
                                  _DonutPainter(valid, expiring, expired),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('$percent%',
                                            style: const TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.w800)),
                                        const Text('Valid',
                                            style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _Legend(const Color(0xFF16A34A), 'Valid',
                                      valid),
                                  _Legend(const Color(0xFFF59E0B),
                                      'Expiring Soon', expiring),
                                  _Legend(AppColors.red, 'Expired', expired),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _Panel(
                          title: 'Recent Batches',
                          trailing: InkWell(
                            onTap: () => setState(() => _selected = 3),
                            child: const Text('View All →',
                                style: TextStyle(
                                    color: AppColors.red,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12)),
                          ),
                          child: recent.isEmpty
                              ? Center(
                            child: Text(
                              _loading
                                  ? 'Loading...'
                                  : 'No extinguisher batches yet.',
                              style:
                              const TextStyle(color: AppColors.grey),
                            ),
                          )
                              : Column(
                            children: [
                              for (final e in recent)
                                _Activity(
                                  statusIcon(e.status),
                                  statusColor(e.status),
                                  e.model,
                                  '${e.batchSize} units • Expires ${formatDate(e.expiryDate)}',
                                  timeAgo(e.createdAt),
                                ),
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
                                          onPressed: _showGuidelines,
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
                            children: [
                              _QuickAction(Icons.add_box, 'Add Batch',
                                      () => setState(() => _selected = 3)),
                              _QuickAction(Icons.refresh, 'Refresh', _refresh),
                              _QuickAction(Icons.logout, 'Logout', _logout),
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

class _ComingSoon extends StatelessWidget {
  final String title;
  const _ComingSoon({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.construction, size: 56, color: AppColors.grey),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy)),
          const SizedBox(height: 4),
          const Text('Coming soon. The backend has no endpoints for this yet.',
              style: TextStyle(color: AppColors.grey)),
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
        width: 150,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                Text(subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.grey)),
              ],
            ),
          ),
          const SizedBox(width: 8),
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
  final VoidCallback onTap;
  const _QuickAction(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
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
  final int valid, expiring, expired;
  _DonutPainter(this.valid, this.expiring, this.expired);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 22.0;
    final rect = Rect.fromLTWH(
        stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    final total = valid + expiring + expired;

    if (total == 0) {
      // Empty state: a plain grey ring.
      canvas.drawArc(
        rect,
        0,
        2 * math.pi,
        false,
        Paint()
          ..color = AppColors.border
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke,
      );
      return;
    }

    final parts = [
      (valid, const Color(0xFF16A34A)),
      (expiring, const Color(0xFFF59E0B)),
      (expired, AppColors.red),
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
      old.valid != valid || old.expiring != expiring || old.expired != expired;
}