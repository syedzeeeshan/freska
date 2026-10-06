import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freska_rider/shared/widgets/sliders/swipe_action_button.dart';

void main() {
  testWidgets(
      'SwipeActionButton renders label and triggers onSwipeComplete when dragged',
      (tester) async {
    bool wasTriggered = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              child: SwipeActionButton(
                label: 'Swipe to Accept',
                onSwipeComplete: () {
                  wasTriggered = true;
                },
              ),
            ),
          ),
        ),
      ),
    );

    // Verify label is visible
    expect(find.text('Swipe to Accept'), findsOneWidget);

    // Find the thumb (Icon with arrow_forward_rounded)
    final thumbFinder = find.byIcon(Icons.arrow_forward_rounded);
    expect(thumbFinder, findsOneWidget);

    // Drag from thumb to the right across the track
    await tester.drag(thumbFinder, const Offset(260.0, 0.0));
    await tester.pumpAndSettle();

    // Verify completion callback fired
    expect(wasTriggered, isTrue);
  });
}
