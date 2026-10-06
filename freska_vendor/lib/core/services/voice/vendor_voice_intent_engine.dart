import 'package:flutter/foundation.dart';
import '../../network/api_client.dart';

class VendorVoiceIntentResult {
  final String intent;
  final String responseText;
  final String? targetRoute;
  final Map<String, dynamic>? parameters;
  final bool requiresConfirmation;
  final String? confirmationPrompt;

  const VendorVoiceIntentResult({
    required this.intent,
    required this.responseText,
    this.targetRoute,
    this.parameters,
    this.requiresConfirmation = false,
    this.confirmationPrompt,
  });
}

class VendorVoiceIntentEngine {
  final ApiClient _apiClient;

  VendorVoiceIntentEngine({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<VendorVoiceIntentResult> processCommand(String transcript) async {
    final query = transcript.trim();
    if (query.isEmpty) {
      return const VendorVoiceIntentResult(
        intent: 'UNKNOWN',
        responseText: 'Please speak a store command, like "Show pending orders" or "Check today\'s sales".',
      );
    }

    // Attempt backend NLP endpoint
    try {
      final response = await _apiClient.post(
        '/voice/intent',
        data: {
          'text': query,
          'role': 'vendor',
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final intent = data['intent'] as String;
        final spokenResponse = data['response_text'] as String;
        final targetRoute = data['target_route'] as String?;
        final requiresConfirmation = data['requires_confirmation'] == true;
        final confirmationPrompt = data['confirmation_prompt'] as String?;

        return VendorVoiceIntentResult(
          intent: intent,
          responseText: spokenResponse,
          targetRoute: targetRoute,
          parameters: data['parameters'] as Map<String, dynamic>?,
          requiresConfirmation: requiresConfirmation,
          confirmationPrompt: confirmationPrompt,
        );
      }
    } catch (e) {
      debugPrint('[VendorVoiceIntent] API error, falling back to local engine: $e');
    }

    // Local deterministic intent classifier fallback
    return _parseLocally(query);
  }

  VendorVoiceIntentResult _parseLocally(String query) {
    final q = query.toLowerCase();

    // 1. Mark Order Ready
    if (q.contains('ready') || q.contains('mark ready')) {
      final match = RegExp(r'\d+').firstMatch(q);
      final orderId = match?.group(0) ?? '89421';
      return VendorVoiceIntentResult(
        intent: 'MARK_ORDER_READY',
        responseText: 'Preparing to mark order #$orderId as ready for rider pickup.',
        parameters: {'order_id': orderId, 'status': 'ready'},
        requiresConfirmation: true,
        confirmationPrompt: 'Are you sure you want to mark order #$orderId as ready for pickup?',
      );
    }

    // 2. Mark Order Preparing
    if (q.contains('preparing') || q.contains('start cooking') || q.contains('start prep')) {
      final match = RegExp(r'\d+').firstMatch(q);
      final orderId = match?.group(0) ?? '89421';
      return VendorVoiceIntentResult(
        intent: 'UPDATE_ORDER_STATUS',
        responseText: 'Updating order #$orderId status to preparing.',
        parameters: {'order_id': orderId, 'status': 'preparing'},
      );
    }

    // 3. Today's Earnings / Sales
    if (q.contains('sale') || q.contains('earn') || q.contains('revenue') || q.contains('income')) {
      return const VendorVoiceIntentResult(
        intent: 'CHECK_EARNINGS',
        responseText: 'Opening your store earnings and revenue overview.',
        targetRoute: '/earnings',
      );
    }

    // 4. Show Pending / Active Orders
    if (q.contains('pending') || q.contains('new order') || q.contains('queue') || q.contains('incoming')) {
      return const VendorVoiceIntentResult(
        intent: 'VIEW_PENDING_ORDERS',
        responseText: 'Showing your active and pending orders.',
        targetRoute: '/orders?tab=pending',
      );
    }

    // 5. Show All Orders
    if (q.contains('order') || q.contains('history')) {
      return const VendorVoiceIntentResult(
        intent: 'VIEW_ORDERS',
        responseText: 'Opening store order list.',
        targetRoute: '/orders',
      );
    }

    // 6. Menu Management / Inventory
    if (q.contains('menu') || q.contains('stock') || q.contains('item') || q.contains('dish') || q.contains('inventory')) {
      return const VendorVoiceIntentResult(
        intent: 'MANAGE_MENU',
        responseText: 'Opening store menu and stock catalog.',
        targetRoute: '/menu',
      );
    }

    // 7. Toggle Store Status (Open / Close)
    if (q.contains('close store') || q.contains('close shop') || q.contains('close kitchen') || q.contains('go offline')) {
      return const VendorVoiceIntentResult(
        intent: 'TOGGLE_STORE_STATUS',
        responseText: 'Closing store for incoming orders.',
        parameters: {'action': 'close'},
        requiresConfirmation: true,
        confirmationPrompt: 'Do you want to switch your store to CLOSED?',
      );
    }

    if (q.contains('open store') || q.contains('open shop') || q.contains('open kitchen') || q.contains('go online')) {
      return const VendorVoiceIntentResult(
        intent: 'TOGGLE_STORE_STATUS',
        responseText: 'Opening store to receive customer orders.',
        parameters: {'action': 'open'},
      );
    }

    // 8. Profile / Settings
    if (q.contains('profile') || q.contains('setting') || q.contains('store info') || q.contains('timing')) {
      return const VendorVoiceIntentResult(
        intent: 'NAVIGATE_PROFILE',
        responseText: 'Opening store profile and operational hours.',
        targetRoute: '/profile',
      );
    }

    // 9. Dashboard / Home
    if (q.contains('home') || q.contains('dashboard') || q.contains('main')) {
      return const VendorVoiceIntentResult(
        intent: 'NAVIGATE_HOME',
        responseText: 'Returning to operations dashboard.',
        targetRoute: '/dashboard',
      );
    }

    return VendorVoiceIntentResult(
      intent: 'UNKNOWN',
      responseText: 'I heard "$query". You can say "Show pending orders", "Check sales", or "Mark order ready".',
    );
  }
}
