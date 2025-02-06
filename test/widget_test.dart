import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alumniihub/welcomescreen.dart';
import 'package:alumniihub/loginscreen.dart';
import 'package:alumniihub/registrationscreen.dart';

void main() {
  testWidgets('WelcomeScreen widget test', (WidgetTester tester) async {

    await tester.pumpWidget(const MaterialApp(
      home: WelcomeScreen(),
    ));

    // Verify if the WelcomeScreen is rendered.
    expect(find.text('Alumni Hub'), findsOneWidget);
    expect(find.byIcon(Icons.school), findsOneWidget);
    expect(find.text("Don't Have an account?"), findsOneWidget);

    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);


    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle(); // Wait for navigation
    expect(find.byType(RegistrationScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();


    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
