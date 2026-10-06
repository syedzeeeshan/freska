import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/vendor_theme.dart';
import 'freska_vendor_button.dart';

class FreskaVendorErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final bool isAuthError;

  const FreskaVendorErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.isAuthError = false,
  });

  @override
  Widget build(BuildContext context) {
    final is401 = isAuthError || message.contains('401') || message.toLowerCase().contains('unauthenticated');

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: (is401 ? FreskaVendorColors.primary : FreskaVendorColors.statusError).withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: (is401 ? FreskaVendorColors.primary : FreskaVendorColors.statusError).withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                is401 ? Icons.lock_outline_rounded : Icons.cloud_off_rounded,
                size: 34,
                color: is401 ? FreskaVendorColors.primary : FreskaVendorColors.statusError,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              is401 ? 'Merchant Authentication Required' : 'Connection Interrupted',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              is401
                  ? 'Please sign in with your registered vendor phone number to access store dispatch and live orders.'
                  : 'Unable to synchronize store telemetry with kitchen backend. Please check network connection.',
              style: const TextStyle(
                fontSize: 13,
                color: FreskaVendorColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (is401)
              FreskaVendorButton(
                label: 'Sign In to Store',
                icon: Icons.login_rounded,
                onPressed: () => context.push('/login'),
              )
            else if (onRetry != null)
              FreskaVendorButton(
                label: 'Retry Connection',
                icon: Icons.refresh_rounded,
                onPressed: onRetry!,
              ),
          ],
        ),
      ),
    );
  }
}

class FreskaVendorEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const FreskaVendorEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.inbox_rounded,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: FreskaVendorColors.bgElevated,
                shape: BoxShape.circle,
                border: Border.all(color: FreskaVendorColors.bgSubtle),
              ),
              child: Icon(icon, size: 30, color: FreskaVendorColors.textMuted),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: FreskaVendorColors.textSecondary, height: 1.4),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              FreskaVendorButton(
                label: actionLabel!,
                onPressed: onAction!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
