import 'package:flutter/material.dart';
import '../models/extinguisher.dart';
import 'appcolors.dart';

Color statusColor(EquipStatus s) {
  switch (s) {
    case EquipStatus.valid:
      return const Color(0xFF16A34A);
    case EquipStatus.expiringSoon:
      return const Color(0xFFF59E0B);
    case EquipStatus.expired:
      return AppColors.red;
  }
}

String statusLabel(EquipStatus s) {
  switch (s) {
    case EquipStatus.valid:
      return 'Valid';
    case EquipStatus.expiringSoon:
      return 'Expiring Soon';
    case EquipStatus.expired:
      return 'Expired';
  }
}

IconData statusIcon(EquipStatus s) {
  switch (s) {
    case EquipStatus.valid:
      return Icons.check_circle;
    case EquipStatus.expiringSoon:
      return Icons.schedule;
    case EquipStatus.expired:
      return Icons.error;
  }
}

class StatusChip extends StatelessWidget {
  final EquipStatus status;
  const StatusChip(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(statusLabel(status),
          style: TextStyle(
              color: c, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}
