import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String userEmail;

  const HomePage({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        backgroundColor: const Color(0xFF0A2647), // Dark blue color for the app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome to the App!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A2647), // Dark blue color for the heading
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Logged in as: $userEmail',
              style: const TextStyle(fontSize: 18, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Button to navigate to the dashboard or main feature
            ElevatedButton(
              onPressed: () {
                // Implement the dashboard or main feature navigation here
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DashboardScreen(), // Placeholder for your dashboard page
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A2647),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                'Go to Dashboard',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            // Button to navigate to the profile page
            ElevatedButton(
              onPressed: () {
                // Implement the profile page navigation here
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(), // Placeholder for your profile page
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                'View Profile',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            // Button to navigate to the settings page
            ElevatedButton(
              onPressed: () {
                // Implement the settings page navigation here
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(), // Placeholder for your settings page
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                'Settings',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 40),

            // Logout Button
            ElevatedButton(
              onPressed: () {
                // Implement the logout functionality
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Example placeholder for DashboardScreen
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF0A2647),
      ),
      body: const Center(
        child: Text(
          'This is the dashboard!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

// Example placeholder for ProfileScreen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF0A2647),
      ),
      body: const Center(
        child: Text(
          'This is the profile page!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

// Example placeholder for SettingsScreen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF0A2647),
      ),
      body: const Center(
        child: Text(
          'This is the settings page!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}