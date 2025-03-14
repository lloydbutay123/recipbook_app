import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recepies_app/pages/home_page.dart';
import 'package:recepies_app/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  static const String routeName = "/login";

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
      width: MediaQuery.sizeOf(context).width * 0.95,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hello",
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text("Welcome Back!", style: TextStyle(fontSize: 35)),
        ],
      ),
    );
  }

  final formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> signInWithEmailAndPassword() async {
    setState(() {
      isLoading = true;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Login failed: $e")));
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
      height: MediaQuery.sizeOf(context).height * 0.30,
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15), // Rounded border
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
                  borderRadius: BorderRadius.circular(15), // Rounded border
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                labelStyle: const TextStyle(color: Colors.black),
                labelText: "Password",
                hintText: "Enter Password",
              ),
            ),
            _loginButton(),
            Text("Sign up with"),
            _signInScreen(),
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
          await signInWithEmailAndPassword();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orangeAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text("Login"),
      ),
    );
  }

  Widget _signInScreen() {
    final AuthService authService = AuthService();
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              final user = await authService.signInWithGoogle();
              if (user != null) {
                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(user.uid)
                    .set({
                      "userId": user.uid,
                      "name": user.displayName,
                      "email": user.email,
                      "createdAt": DateTime.now(),
                    });
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Login successful!")));
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                }
              }
            },
            child: Image.asset(
              "assets/images/google.png",
              width: 30,
              height: 30,
            ),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: () async {
              final user = await authService.signInWithFacebook();
              if (user != null) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Login successful!")));
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                }
              }
            },
            child: Image.asset(
              "assets/images/facebook.png",
              width: 30,
              height: 30,
            ),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: () async {
              final user = await authService.signInWithFacebook();
              if (user != null) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Login successful!")));
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                }
              }
            },
            child: Image.asset(
              "assets/images/twitter.png",
              width: 30,
              height: 30,
            ),
          ),
        ],
      ),
    );
  }
}
