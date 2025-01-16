import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alumniihub/welcomescreen.dart';
import 'package:alumniihub/loginscreen.dart';
import 'package:alumniihub/registrationscreen.dart';

// main() function to start the tests
void main() {
  testWidgets('WelcomeScreen widget test', (WidgetTester tester) async {
    // Build the WelcomeScreen widget.
    await tester.pumpWidget(const MaterialApp(
      home: WelcomeScreen(),
    ));

    // Verify if the WelcomeScreen is rendered.
    expect(find.text('Alumni Hub'), findsOneWidget);
    expect(find.byIcon(Icons.school), findsOneWidget);
    expect(find.text("Don't Have an account?"), findsOneWidget);

    // Verify if the Sign Up and Login buttons exist.
    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);

    // Tap the 'Sign Up' button and verify navigation to RegistrationScreen.
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle(); // Wait for navigation
    expect(find.byType(RegistrationScreen), findsOneWidget);

    // Go back to WelcomeScreen
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Tap the 'Login' button and verify navigation to LoginScreen.
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle(); // Wait for navigation
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
