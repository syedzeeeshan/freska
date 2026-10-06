import 'package:flutter/foundation.dart';
import '../../network/api_client.dart';

class CustomerVoiceIntentResult {
  final String intent;
  final String spokenResponse;
  final String? targetRoute;
  final Map<String, dynamic>? data;

  const CustomerVoiceIntentResult({
    required this.intent,
    required this.spokenResponse,
    this.targetRoute,
    this.data,
  });

  factory CustomerVoiceIntentResult.fromJson(Map<String, dynamic> json) {
    return CustomerVoiceIntentResult(
      intent: json['intent'] as String? ?? 'GENERAL_QUERY',
      spokenResponse: json['spoken_response'] as String? ?? 'Command processed.',
      targetRoute: json['target_route'] as String?,
      data: json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : null,
    );
  }
}

class CustomerVoiceIntentEngine {
  final ApiClient _apiClient;

  CustomerVoiceIntentEngine({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<CustomerVoiceIntentResult> processCommand(String query) async {
    final cleaned = query.trim();
    if (cleaned.isEmpty) {
      return const CustomerVoiceIntentResult(
        intent: 'EMPTY',
        spokenResponse: 'I did not catch that. Please try asking again.',
      );
    }

    try {
      final response = await _apiClient.post(
        '/voice/intent',
        data: {
          'query': cleaned,
          'role': 'customer',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as Map<String, dynamic>?;
        if (data != null) {
          return CustomerVoiceIntentResult.fromJson(data);
        }
      }
    } catch (e) {
      debugPrint('[CustomerVoiceIntent] API error, using local intent parser: $e');
    }

    // Local deterministic fallback
    final q = cleaned.toLowerCase();
    if (q.contains('find') || q.contains('search') || q.contains('want') || q.contains('biryani') || q.contains('milk') || q.contains('strawberry') || q.contains('bread')) {
      final keyword = q.replaceAll(RegExp(r'^(find|search for|search|show me)\s+'), '').trim();
      return CustomerVoiceIntentResult(
        intent: 'SEARCH_FOOD',
        spokenResponse: "Searching Freska stores for '$keyword'.",
        targetRoute: '/search?q=${Uri.encodeComponent(keyword)}',
      );
    }

    if (q.contains('cart') || q.contains('basket')) {
      return const CustomerVoiceIntentResult(
        intent: 'OPEN_CART',
        spokenResponse: 'Opening your shopping cart.',
        targetRoute: '/cart',
      );
    }

    if (q.contains('track') || q.contains('where is my') || q.contains('order')) {
      return const CustomerVoiceIntentResult(
        intent: 'TRACK_ORDER',
        spokenResponse: 'Opening your orders.',
        targetRoute: '/orders',
      );
    }

    if (q.contains('address')) {
      return const CustomerVoiceIntentResult(
        intent: 'OPEN_ADDRESSES',
        spokenResponse: 'Showing your saved delivery addresses.',
        targetRoute: '/addresses',
      );
    }

    return const CustomerVoiceIntentResult(
      intent: 'GENERAL_HELP',
      spokenResponse: 'You can ask me to find food, check your cart, or track your active orders.',
    );
  }
}
