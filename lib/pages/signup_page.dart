import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recepies_app/pages/login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  static const String routeName = "/signup";

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
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
        children: [_title(), _loginForm()],
      ),
    );
  }

  Widget _title() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.90,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome!",
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text("Create your Account", style: TextStyle(fontSize: 35)),
        ],
      ),
    );
  }

  final formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> createUsernameWithEmailAndPassword() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      User? user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(_nameController.text.trim());
        await user.reload();
      }

      if (mounted) {
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
      width: MediaQuery.sizeOf(context).width * 0.90,
      height: MediaQuery.sizeOf(context).height * 0.30,
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
            _loginButton(),
            _goToLogin(),
          ],
        ),
      ),
    );
  }

  Widget _loginButton() {
    return SizedBox(
      height: 60,
      width: MediaQuery.sizeOf(context).width,
      child: ElevatedButton(
        onPressed: () async {
          await createUsernameWithEmailAndPassword();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orangeAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text("Register"),
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
