import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Add this
import 'package:ungthoung_app/main.dart';

void main() {
  testWidgets('App loads and shows Login screen by default', (
    WidgetTester tester,
  ) async {
    // 1. Wrap MyApp in a ProviderScope so Riverpod works in the test
    // 2. Remove "isLoggedIn: false" because your MyApp constructor doesn't have it
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // 3. Check for something actually on your LoginUser screen
    // Since you aren't logged in, _getHome will return LoginUser()
    expect(find.byType(TextField), findsAtLeastNWidgets(1));
    expect(find.text('Login'), findsWidgets);
  });
}
