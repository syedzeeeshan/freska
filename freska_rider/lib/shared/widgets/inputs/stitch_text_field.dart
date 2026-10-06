import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/stitch_colors.dart';
import '../../../core/theme/stitch_typography.dart';

class StitchTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? labelText;
  final String? hintText;
  final String? prefixText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool obscureText;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final int? maxLines;
  final int? minLines;

  const StitchTextField({
    super.key,
    required this.controller,
    this.label,
    this.labelText,
    this.hintText,
    this.prefixText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.enabled = true,
    this.obscureText = false,
    this.focusNode,
    this.onChanged,
    this.maxLines = 1,
    this.minLines,
  });

  String? get _effectiveLabel => labelText ?? label;

  @override
  Widget build(BuildContext context) {
    final displayLabel = _effectiveLabel;
    final effectiveMaxLines = obscureText ? 1 : maxLines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (displayLabel != null && displayLabel.isNotEmpty) ...[
          Text(
            displayLabel,
            style: StitchTypography.bodyEmphasis,
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          enabled: enabled,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          focusNode: focusNode,
          onChanged: onChanged,
          maxLines: effectiveMaxLines,
          minLines: minLines,
          style: StitchTypography.bodyEmphasis.copyWith(fontSize: 15),
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
            prefixText: prefixText != null ? '$prefixText ' : null,
            prefixStyle: StitchTypography.bodyEmphasis.copyWith(
              color: StitchColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
