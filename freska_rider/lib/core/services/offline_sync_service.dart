import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:hive_flutter/hive_flutter.dart';
import '../network/api_client.dart';

class OfflineSyncService {
  final ApiClient apiClient;
  late Box<String> _pendingActionsBox;
  bool _isSyncing = false;

  OfflineSyncService({required this.apiClient});

  Future<void> init() async {
    _pendingActionsBox = await Hive.openBox<String>('pending_actions_box');
  }

  Future<void> queueAction({
    required String endpoint,
    required String method,
    Map<String, dynamic>? data,
  }) async {
    final payload = {
      'endpoint': endpoint,
      'method': method,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'attempt': 0,
    };

    await _pendingActionsBox.add(jsonEncode(payload));
  }

  Future<void> processQueue() async {
    if (_isSyncing || _pendingActionsBox.isEmpty) return;
    _isSyncing = true;

    final keys = _pendingActionsBox.keys.toList();

    for (final key in keys) {
      final raw = _pendingActionsBox.get(key);
      if (raw == null) continue;

      try {
        final Map<String, dynamic> item = jsonDecode(raw);
        final endpoint = item['endpoint'] as String;
        final method = item['method'] as String;
        final data = item['data'] as Map<String, dynamic>?;

        if (method.toUpperCase() == 'POST') {
          await apiClient.post(endpoint, data: data);
        } else if (method.toUpperCase() == 'PATCH') {
          await apiClient.patch(endpoint, data: data);
        } else if (method.toUpperCase() == 'PUT') {
          await apiClient.put(endpoint, data: data);
        }

        // Successfully executed on server
        await _pendingActionsBox.delete(key);
      } catch (e) {
        // Exponential backoff and retry tracking
        final Map<String, dynamic> item = jsonDecode(raw);
        int attempts = (item['attempt'] as int? ?? 0) + 1;

        if (attempts >= 5) {
          // Discard after 5 failed attempts to prevent infinite loop
          await _pendingActionsBox.delete(key);
        } else {
          item['attempt'] = attempts;
          await _pendingActionsBox.put(key, jsonEncode(item));
          // Wait with jitter: 2^attempt * 1000ms + rand(0, 500ms)
          final waitMs =
              (pow(2, attempts) * 1000).toInt() + Random().nextInt(500);
          await Future.delayed(Duration(milliseconds: waitMs));
        }
        break; // Pause queue processing if connection failed
      }
    }

    _isSyncing = false;
  }

  int get pendingCount => _pendingActionsBox.length;
}
