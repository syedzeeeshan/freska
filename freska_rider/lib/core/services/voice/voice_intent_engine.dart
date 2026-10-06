import 'package:flutter/foundation.dart';
import '../../network/api_client.dart';

enum FreskaVoiceRole { customer, vendor, rider }

class VoiceIntentResult {
  final String intent;
  final String spokenResponse;
  final bool requiresConfirmation;
  final String? confirmationPrompt;
  final String? targetRoute;
  final String? targetAction;
  final Map<String, dynamic>? data;

  const VoiceIntentResult({
    required this.intent,
    required this.spokenResponse,
    this.requiresConfirmation = false,
    this.confirmationPrompt,
    this.targetRoute,
    this.targetAction,
    this.data,
  });

  factory VoiceIntentResult.fromJson(Map<String, dynamic> json) {
    return VoiceIntentResult(
      intent: json['intent'] as String? ?? 'GENERAL_QUERY',
      spokenResponse: json['spoken_response'] as String? ?? 'Command processed.',
      requiresConfirmation: json['requires_confirmation'] as bool? ?? false,
      confirmationPrompt: json['confirmation_prompt'] as String?,
      targetRoute: json['target_route'] as String?,
      targetAction: json['target_action'] as String?,
      data: json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : null,
    );
  }
}

class VoiceIntentEngine {
  final ApiClient? _apiClient;

  VoiceIntentEngine({ApiClient? apiClient}) : _apiClient = apiClient;

  Future<VoiceIntentResult> processCommand({
    required String query,
    required FreskaVoiceRole role,
  }) async {
    final cleaned = query.trim();
    if (cleaned.isEmpty) {
      return const VoiceIntentResult(
        intent: 'EMPTY_QUERY',
        spokenResponse: 'I did not catch that. Please speak again.',
      );
    }

    try {
      if (_apiClient != null) {
        final response = await _apiClient.post(
          '/voice/intent',
          data: {
            'query': cleaned,
            'role': role.name,
          },
        );

        if (response.statusCode == 200 && response.data != null) {
          final data = response.data['data'] as Map<String, dynamic>?;
          if (data != null) {
            return VoiceIntentResult.fromJson(data);
          }
        }
      }
    } catch (e) {
      debugPrint('[VoiceIntentEngine] Server intent failure, falling back to local NLP: $e');
    }

    // Local deterministic fallback
    return _processLocalNlp(cleaned, role);
  }

  VoiceIntentResult _processLocalNlp(String query, FreskaVoiceRole role) {
    final q = query.toLowerCase();

    switch (role) {
      case FreskaVoiceRole.customer:
        if (q.contains('find') || q.contains('search') || q.contains('biryani') || q.contains('pizza') || q.contains('milk') || q.contains('bread')) {
          final keyword = q.replaceAll(RegExp(r'^(find|search for|search|show me)\s+'), '').trim();
          return VoiceIntentResult(
            intent: 'SEARCH_FOOD',
            spokenResponse: "Searching Freska for '$keyword'.",
            targetRoute: '/search?q=${Uri.encodeComponent(keyword)}',
            data: {'query': keyword},
          );
        }
        if (q.contains('track') || q.contains('where is my') || q.contains('order status')) {
          return const VoiceIntentResult(
            intent: 'TRACK_ORDER',
            spokenResponse: 'Opening your active order tracking.',
            targetRoute: '/orders',
          );
        }
        if (q.contains('cart') || q.contains('basket')) {
          return const VoiceIntentResult(
            intent: 'OPEN_CART',
            spokenResponse: 'Opening your shopping cart.',
            targetRoute: '/cart',
          );
        }
        if (q.contains('address') || q.contains('location')) {
          return const VoiceIntentResult(
            intent: 'OPEN_ADDRESSES',
            spokenResponse: 'Opening your saved addresses.',
            targetRoute: '/addresses',
          );
        }
        return const VoiceIntentResult(
          intent: 'CUSTOMER_HELP',
          spokenResponse: 'You can ask me to search for food, view cart, or track your orders.',
        );

      case FreskaVoiceRole.vendor:
        if (q.contains('ready')) {
          return const VoiceIntentResult(
            intent: 'MARK_ORDER_READY',
            spokenResponse: 'Please confirm marking the order ready for delivery pickup.',
            requiresConfirmation: true,
            confirmationPrompt: 'Confirm marking order as ready?',
          );
        }
        if (q.contains('order') || q.contains('pending') || q.contains('new')) {
          return const VoiceIntentResult(
            intent: 'SHOW_ORDERS',
            spokenResponse: 'Opening your store order management queue.',
            targetRoute: '/vendor/orders',
          );
        }
        if (q.contains('sales') || q.contains('earning') || q.contains('revenue')) {
          return const VoiceIntentResult(
            intent: 'SHOW_EARNINGS',
            spokenResponse: "Opening today's store earnings dashboard.",
            targetRoute: '/vendor/earnings',
          );
        }
        return const VoiceIntentResult(
          intent: 'VENDOR_HELP',
          spokenResponse: 'You can ask for new orders, today sales, or check store earnings.',
        );

      case FreskaVoiceRole.rider:
        if (q.contains('go online') || q.contains('start duty')) {
          return const VoiceIntentResult(
            intent: 'TOGGLE_DUTY_ONLINE',
            spokenResponse: 'Switching duty status to Online. Searching for nearby orders.',
            targetAction: 'GO_ONLINE',
          );
        }
        if (q.contains('go offline') || q.contains('stop duty')) {
          return const VoiceIntentResult(
            intent: 'TOGGLE_DUTY_OFFLINE',
            spokenResponse: 'Switching duty status to Offline.',
            targetAction: 'GO_OFFLINE',
          );
        }
        if (q.contains('order') || q.contains('current') || q.contains('navigate')) {
          return const VoiceIntentResult(
            intent: 'SHOW_CURRENT_ORDER',
            spokenResponse: 'Opening active order navigation.',
            targetRoute: '/orders/delivery',
          );
        }
        if (q.contains('earning') || q.contains('payout')) {
          return const VoiceIntentResult(
            intent: 'SHOW_EARNINGS',
            spokenResponse: 'Opening your rider earnings ledger.',
            targetRoute: '/earnings',
          );
        }
        if (q.contains('repeat') || q.contains('again')) {
          return const VoiceIntentResult(
            intent: 'REPEAT_NAVIGATION',
            spokenResponse: 'Repeating last spoken navigation instruction.',
            targetAction: 'REPEAT_TTS',
          );
        }
        return const VoiceIntentResult(
          intent: 'RIDER_HELP',
          spokenResponse: "You can say 'Go online', 'Show current order', or 'Show earnings'.",
        );
    }
  }
}
