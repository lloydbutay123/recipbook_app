import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? "";
    }

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .get();

    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      _phoneController.text = userData['phone'] ?? "";
      _dobController.text = userData['dob'] ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Update Profile"), centerTitle: true),
      body: SafeArea(child: _buildUi()),
    );
  }

  Widget _buildUi() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_updateProfileForm()],
        ),
      ),
    );
  }

  Future<void> _updateProfile() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    User? user = _auth.currentUser;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      await user.updateDisplayName(_nameController.text);
      await user.reload();

      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);

      await userDocRef.update({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'dob': _dobController.text,
      });

      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error updating profile: $e")));
      }
    }
  }

  Widget _updateProfileForm() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.95,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text(
              "Name",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 2.5),
                ),
                hintText: "Enter your name",
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Name cannot be empty";
                }
                return null;
              },
            ),

            const SizedBox(height: 20),
            const Text(
              "Phone Number",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 2.5),
                ),
                hintText: "Enter your phone number",
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Phone number cannot be empty";
                }
                return null;
              },
            ),

            const SizedBox(height: 20),
            const Text(
              "Date of Birth",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: _dobController,
              readOnly: true,
              onTap: () => _selectDate(context),
              decoration: InputDecoration(
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 2.5),
                ),
                hintText: "Enter your date of birth",
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Date of Birth cannot be empty";
                }
                return null;
              },
            ),
            SizedBox(height: 40),
            _updateProfileButton(),
          ],
        ),
      ),
    );
  }

  Widget _updateProfileButton() {
    return SizedBox(
      height: 60,
      width: MediaQuery.sizeOf(context).width * 0.95,
      child: ElevatedButton(
        onPressed: () async {
          await _updateProfile();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orangeAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          "Update Profile".toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default selection
      firstDate: DateTime(1900), // Minimum selectable date
      lastDate: DateTime.now(), // Maximum selectable date
    );

    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }
}
