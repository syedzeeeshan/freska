import 'package:flutter/material.dart';
import '../../../../core/theme/stitch_colors.dart';

class OfflineIndicatorBanner extends StatelessWidget {
  final bool isOffline;
  final int pendingSyncCount;

  const OfflineIndicatorBanner({
    super.key,
    required this.isOffline,
    this.pendingSyncCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOffline && pendingSyncCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isOffline ? StitchColors.dangerSOS : StitchColors.accentGold,
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Icon(
              isOffline ? Icons.wifi_off_rounded : Icons.sync_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isOffline
                    ? 'Offline Mode. Actions will auto-sync when network returns.'
                    : 'Syncing $pendingSyncCount offline actions to Freska server…',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
