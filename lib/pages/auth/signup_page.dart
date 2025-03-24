import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recepies_app/pages/auth/login_page.dart';
import 'package:recepies_app/widgets/custom_button.dart';
import 'package:recepies_app/widgets/custom_title.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  static const String routeName = "/signup";

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: _buildUi()));
  }

  Widget _buildUi() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomTitle(title: "Welcome!", subTitle: "Create your Account"),
          _loginForm(),
        ],
      ),
    );
  }

  Future<void> createUsernameWithEmailAndPassword() async {
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      User? user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(_nameController.text.trim());

        await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          "userId": user.uid,
          "name": _nameController.text.trim(),
          "email": _emailController.text.trim(),
          "createdAt": DateTime.now(),
        });
      }

      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration successful! Please log in")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Register failed: $e")));
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _loginForm() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.95,
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              controller: _nameController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded border
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                labelStyle: const TextStyle(color: Colors.black),
                labelText: "Name",
                hintText: "Enter your Name",
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded border
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                labelStyle: const TextStyle(color: Colors.black),
                labelText: "Email",
                hintText: "Enter Email Address",
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _passwordController,
              keyboardType: TextInputType.text,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded border
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                labelStyle: const TextStyle(color: Colors.black),
                labelText: "Password",
                hintText: "Enter Password",
              ),
            ),
            SizedBox(height: 10),
            CustomButton(
              label: "Register",
              isLoading: isLoading,
              backgroundColor: Colors.orangeAccent,
              fontSize: 14,
              fontWeight: FontWeight.normal,
              onPressed:
                  isLoading
                      ? null
                      : () async {
                        await createUsernameWithEmailAndPassword();
                      },
            ),
            _goToLogin(),
          ],
        ),
      ),
    );
  }

  Widget _goToLogin() {
    return TextButton(
      style: TextButton.styleFrom(foregroundColor: Colors.black),
      onPressed: () {
        Navigator.pushReplacementNamed(context, LoginPage.routeName);
      },
      child: Text("Already have an account?"),
    );
  }
}
