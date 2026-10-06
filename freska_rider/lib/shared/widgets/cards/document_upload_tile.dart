import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/stitch_colors.dart';
import '../../../core/theme/stitch_spacing.dart';
import 'stitch_surface_card.dart';

class DocumentUploadTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final File? selectedFile;
  final bool isRequired;
  final ValueChanged<File> onFileSelected;
  final VoidCallback? onRemove;

  const DocumentUploadTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selectedFile,
    this.isRequired = true,
    required this.onFileSelected,
    this.onRemove,
  });

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1920,
      maxHeight: 1080,
    );

    if (pickedFile != null) {
      onFileSelected(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFile = selectedFile != null;

    return StitchSurfaceCard(
      padding: const EdgeInsets.all(StitchSpacing.cardPadding),
      border: Border.all(
        color: hasFile ? StitchColors.primary : StitchColors.surfaceBorder,
        width: hasFile ? 1.5 : 1.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: hasFile
                      ? StitchColors.primary.withValues(alpha: 0.15)
                      : StitchColors.surfaceElevated,
                  borderRadius:
                      BorderRadius.circular(StitchSpacing.borderRadiusSm),
                ),
                child: Icon(
                  Icons.document_scanner_rounded,
                  color: hasFile
                      ? StitchColors.primaryLight
                      : StitchColors.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: StitchSpacing.md),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: StitchColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                    children: [
                      if (isRequired)
                        const TextSpan(
                          text: ' *',
                          style: TextStyle(
                            color: StitchColors.danger,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (hasFile)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: StitchColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: StitchColors.primaryLight, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Attached',
                        style: TextStyle(
                          color: StitchColors.primaryLight,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: StitchSpacing.xs),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: StitchColors.textSecondary,
                ),
          ),
          const SizedBox(height: StitchSpacing.md),
          InkWell(
            onTap: () => _pickImage(context),
            borderRadius: BorderRadius.circular(StitchSpacing.borderRadiusMd),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: StitchSpacing.md),
              decoration: BoxDecoration(
                color: StitchColors.surfaceElevated.withValues(alpha: 0.5),
                borderRadius:
                    BorderRadius.circular(StitchSpacing.borderRadiusMd),
                border: Border.all(
                  color: StitchColors.surfaceBorder,
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    hasFile ? Icons.sync_rounded : Icons.upload_file_rounded,
                    color: hasFile
                        ? StitchColors.primaryLight
                        : StitchColors.textSecondary,
                    size: 18,
                  ),
                  const SizedBox(width: StitchSpacing.sm),
                  Text(
                    hasFile
                        ? 'Change Document'
                        : 'Tap to Upload (JPG, PNG, PDF)',
                    style: TextStyle(
                      color: hasFile
                          ? StitchColors.primaryLight
                          : StitchColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
