import '../core/api_clinet.dart';

import '../models/extinguisher.dart';

class ExtinguisherService {
  ExtinguisherService._();
  static final ExtinguisherService instance = ExtinguisherService._();

  final _api = ApiClient.instance;

  /// GET /api/extinguishers
  Future<List<Extinguisher>> list() async {
    final r = await _api.send('GET', '/api/extinguishers');
    final data = r.json['data'];
    if (data is! List) return [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Extinguisher.fromJson)
        .toList();
  }

  /// POST /api/extinguishers
  Future<void> create({
    required String model,
    required int batchSize,
    required DateTime expiryDate,
    required bool isExpired,
  }) async {
    await _api.send('POST', '/api/extinguishers', body: {
      'model': model,
      'batchSize': batchSize,
      'expiryDate': expiryDate.toUtc().toIso8601String(),
      'isExpired': isExpired,
    });
  }

  /// PUT /api/extinguishers/:id
  Future<void> update(
    String batchId, {
    required String model,
    required int batchSize,
    required DateTime expiryDate,
    required bool isExpired,
  }) async {
    await _api.send('PUT', '/api/extinguishers/$batchId', body: {
      'model': model,
      'batchSize': batchSize,
      'expiryDate': expiryDate.toUtc().toIso8601String(),
      'isExpired': isExpired,
    });
  }

  /// DELETE /api/extinguishers/:id
  Future<void> delete(String batchId) async {
    await _api.send('DELETE', '/api/extinguishers/$batchId');
  }
}
