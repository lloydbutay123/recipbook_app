import 'package:flutter/material.dart';
import 'package:recepies_app/pages/profile/settings/change_password_page.dart';
import 'package:recepies_app/pages/profile/settings/update_profile_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person_outline),
            title: Text("Update Profile"),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UpdateProfilePage(),
                  ),
                ),
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text("Change Password"),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordPage(),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
