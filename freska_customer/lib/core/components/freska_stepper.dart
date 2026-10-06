import 'package:flutter/material.dart';
import '../theme/customer_theme.dart';

class FreskaQuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback? onAddInitial;

  const FreskaQuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.onAddInitial,
  });

  @override
  Widget build(BuildContext context) {
    if (quantity == 0) {
      return Container(
        height: 36,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF29A52), Color(0xFFE87532)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(FreskaRadius.sm),
          border: const Border(
            top: BorderSide(color: Color(0xFFFFAE6B), width: 1.0),
            bottom: BorderSide(color: Color(0xFFC95E27), width: 1.5),
            left: BorderSide(color: Color(0xFFFFAE6B), width: 0.5),
            right: BorderSide(color: Color(0xFFFFAE6B), width: 0.5),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(FreskaRadius.sm),
            onTap: onAddInitial ?? onIncrement,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 15, color: Color(0xFF111315)),
                  SizedBox(width: 4),
                  Text(
                    'ADD',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111315),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: FreskaCustomerColors.tactileSlate,
        borderRadius: BorderRadius.circular(FreskaRadius.sm),
        border: const Border(
          top: BorderSide(color: Color(0xFF3A4148), width: 1.0),
          bottom: BorderSide(color: Color(0xFF181B1F), width: 1.2),
          left: BorderSide(color: Color(0xFF2A3036), width: 1.0),
          right: BorderSide(color: Color(0xFF2A3036), width: 1.0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTactileStepButton(
            icon: Icons.remove,
            onTap: onDecrement,
            isMinus: true,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: FreskaCustomerColors.textPrimary,
              ),
            ),
          ),
          _buildTactileStepButton(
            icon: Icons.add,
            onTap: onIncrement,
            isMinus: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTactileStepButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isMinus,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.horizontal(
          left: isMinus ? const Radius.circular(FreskaRadius.sm - 1) : Radius.zero,
          right: !isMinus ? const Radius.circular(FreskaRadius.sm - 1) : Radius.zero,
        ),
        onTap: onTap,
        splashColor: FreskaCustomerColors.primary.withValues(alpha: 0.2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Icon(icon, size: 15, color: FreskaCustomerColors.primary),
        ),
      ),
    );
  }
}
