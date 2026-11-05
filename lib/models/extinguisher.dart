enum EquipStatus { valid, expiringSoon, expired }

class Extinguisher {
  final String batchId;
  final String model;
  final int batchSize;
  final DateTime expiryDate; // kept in UTC, the server stores midnight UTC
  final bool isExpired;
  final DateTime createdAt;

  const Extinguisher({
    required this.batchId,
    required this.model,
    required this.batchSize,
    required this.expiryDate,
    required this.isExpired,
    required this.createdAt,
  });

  factory Extinguisher.fromJson(Map<String, dynamic> j) => Extinguisher(
        batchId: j['batchId'].toString(),
        model: (j['model'] ?? '').toString(),
        batchSize: (j['batchSize'] as num?)?.toInt() ?? 0,
        expiryDate: DateTime.parse(j['expiryDate'].toString()).toUtc(),
        isExpired: j['isExpired'] as bool? ?? false,
        createdAt: DateTime.parse(j['createdAt'].toString()).toLocal(),
      );

  /// Expired if the server flag is set OR the date has passed.
  /// "Expiring soon" means 90 days or less remain.
  EquipStatus get status {
    final now = DateTime.now().toUtc();
    if (isExpired || expiryDate.isBefore(now)) return EquipStatus.expired;
    if (expiryDate.difference(now).inDays <= 90) return EquipStatus.expiringSoon;
    return EquipStatus.valid;
  }
}
