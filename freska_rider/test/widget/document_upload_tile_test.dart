import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freska_rider/shared/widgets/cards/document_upload_tile.dart';

void main() {
  testWidgets(
      'DocumentUploadTile displays title, subtitle and required asterisk',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DocumentUploadTile(
            title: 'Driving License (Front)',
            subtitle: 'Clear photo showing name and DOB',
            selectedFile: null,
            isRequired: true,
            onFileSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.textContaining('Driving License (Front)', findRichText: true), findsOneWidget);
    expect(find.textContaining('*', findRichText: true), findsOneWidget);
    expect(find.text('Clear photo showing name and DOB'), findsOneWidget);
    expect(find.byIcon(Icons.document_scanner_rounded), findsOneWidget);
    expect(find.byIcon(Icons.upload_file_rounded), findsOneWidget);
  });
}
