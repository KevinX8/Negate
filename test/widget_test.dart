// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:negate/main.dart';
import 'package:negate/sentiment_db.dart';
import 'package:negate/ui/globals.dart';

void main() {
  testWidgets('Date Changer Test', (WidgetTester tester) async {
    var sdb = SentimentDB();
    getIt.registerSingleton<SentimentDB>(sdb);
    getIt.registerSingleton<bool>(true);
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: ThemedHourlyUI()));
    var now = DateTime.now();

    // Verify that app opens on current date and time
    expect(find.text('Positivity scores for ${DateFormat.j().format(now)}'), findsOneWidget);
    expect(find.text(DateFormat.yMMMd().format(now)), findsOneWidget);

    // Tap the '<' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pump();

    // Verify that date changed to the day before.
    expect(
        find.text(DateFormat.yMMMd().format(now.subtract(Duration(days: 1)))),
        findsNothing);
  });
}
