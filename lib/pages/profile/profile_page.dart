import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recepies_app/pages/farovite_page.dart';
import 'package:recepies_app/pages/landing_page.dart';
import 'package:recepies_app/pages/profile/settings/settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LandingPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile"),
        centerTitle: true,
        backgroundColor: Colors.grey.shade100,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // ✅ Manually add back button
          onPressed: () {
            Navigator.pop(context); // ✅ Navigate back when pressed
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              _logout();
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: SafeArea(child: _buildUi()),
    );
  }

  Widget _buildUi() {
    double screenWidth = MediaQuery.sizeOf(context).width;
    return Center(
      child: SizedBox(
        width: screenWidth * 0.95,
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(15),
            ),
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [_profileInfo(), SizedBox(height: 20), _profileMenu()],
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileInfo() {
    User? user = FirebaseAuth.instance.currentUser;
    String? userName = user?.displayName;
    String? userEmail = user?.email;

    return Column(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(50)),
          child: Image.asset(
            "assets/images/johnlloyd.jpg",
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 5),
        Text(
          "$userName",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text("$userEmail"),
      ],
    );
  }

  Widget _profileMenu() {
    return ListView(
      physics: BouncingScrollPhysics(),
      shrinkWrap: true,
      children: [
        _buildMenuItem(Icons.wallet_outlined, "My Wallet", () {}),
        _buildMenuItem(Icons.notifications_outlined, "Notifications", () {}),
        _buildMenuItem(Icons.favorite_outline, "My Favorites", () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FavoritePage()),
          );
        }),
        _buildMenuItem(Icons.settings_outlined, "Settings", () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsPage()),
          );
        }),
        _buildMenuItem(Icons.group_add_outlined, "Invite a Friend", () {}),
        _buildMenuItem(Icons.help_center_outlined, "Help", () {}),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [Icon(icon), SizedBox(width: 5), Text(title)]),
              Icon(Icons.keyboard_arrow_right),
            ],
          ),
        ),
      ),
    );
  }
}
