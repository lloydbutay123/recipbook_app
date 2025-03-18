import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recepies_app/widgets/custom_input_field.dart';
import 'package:recepies_app/widgets/image_container.dart';

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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      // 🔹 Force Firestore to fetch latest data (disable cache)
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get(const GetOptions(source: Source.server));

      if (userDoc.exists) {
        Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;

        setState(() {
          _nameController.text = userData?['name'] ?? user.displayName ?? "";
          _phoneController.text =
              userData?.containsKey('phone') == true ? userData!['phone'] : "";
          _dobController.text =
              userData?.containsKey('dob') == true ? userData!['dob'] : "";
        });
      }
    } catch (e) {
      // Handle error
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

      final userRef = _firestore.collection('users').doc(user.uid);

      await userRef.update({
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
    User? user = FirebaseAuth.instance.currentUser;
    String? photoUrl = user?.photoURL;

    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.95,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Center(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                    child: ImageContainer(
                      imageUrl: photoUrl,
                      width: 120,
                      height: 120,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            CustomInputField(
              label: "Name",
              controller: _nameController,
              errorMessage: "Name cannot be empty",
            ),
            CustomInputField(
              label: "Phone Number",
              controller: _phoneController,
              errorMessage: "Phone number cannot be empty",
            ),
            CustomInputField(
              label: "Date of Birth",
              controller: _dobController,
              errorMessage: "Date of Birth cannot be empty",
              readOnly: true,
              onTap: () {
                _selectDate(context);
              },
            ),

            SizedBox(height: 40),
            _updateProfileButton(),
            SizedBox(height: 10),
            _deleteProfileButton(),
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

  Future<void> _deleteAccount() async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .delete();

      await user?.delete();

      await FirebaseAuth.instance.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Account deleted successfully!")),
        );
        Navigator.pushReplacementNamed(context, "/login");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "You need to log in again before deleting your account.",
              ),
            ),
          );
        }
      }
    }
  }

  Widget _deleteProfileButton() {
    return SizedBox(
      height: 60,
      width: MediaQuery.sizeOf(context).width * 0.95,
      child: ElevatedButton(
        onPressed: () async {
          await _deleteAccount();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          "Delete Account".toUpperCase(),
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
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    setState(() {
      _dobController.text = "${picked?.year}-${picked?.month}-${picked?.day}";
    });
  }
}
