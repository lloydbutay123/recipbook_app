import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile"),
        centerTitle: true,
        backgroundColor: Colors.grey.shade100,
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.exit_to_app))],
      ),
      body: SafeArea(child: _buildUi()),
    );
  }

  Widget _buildUi() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [_profileInfo(), SizedBox(height: 20), _profileMenu()],
          ),
        ),
      ),
    );
  }

  Widget _profileInfo() {
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
          "John Lloyd Butay",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text("johnlloydbutay123@gmail.com"),
      ],
    );
  }

  Widget _profileMenu() {
    return ListView(
      physics: BouncingScrollPhysics(), // ✅ Allows smooth scrolling
      shrinkWrap: true, // ✅ Prevents unnecessary height constraints
      children: [
        _buildMenuItem(Icons.wallet_outlined, "My Wallet"),
        _buildMenuItem(Icons.notifications_outlined, "Notifications"),
        _buildMenuItem(Icons.favorite_outline, "My Favorites"),
        _buildMenuItem(Icons.settings_outlined, "Settings"),
        _buildMenuItem(Icons.group_add_outlined, "Invite a Friend"),
        _buildMenuItem(Icons.help_center_outlined, "Help"),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15), // ✅ Adds spacing
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(5),
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
    );
  }
}
