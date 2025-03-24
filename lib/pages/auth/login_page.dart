import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recepies_app/pages/auth/forgot_password_page.dart';
import 'package:recepies_app/pages/home/home_page.dart';
import 'package:recepies_app/pages/auth/signup_page.dart';
import 'package:recepies_app/services/auth_service.dart';
import 'package:recepies_app/widgets/custom_button.dart';
import 'package:recepies_app/widgets/custom_input_field.dart';
import 'package:recepies_app/widgets/custom_title.dart';

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
        children: [
          CustomTitle(title: "Hello", subTitle: "Welcome back!"),
          _loginForm(),
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
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            CustomInputField(
              label: "Email",
              controller: _emailController,
              errorMessage: "Please enter your email",
              inputBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Colors.grey, width: 1),
              ),
            ),
            SizedBox(height: 10),
            Stack(
              children: [
                CustomInputField(
                  label: 'Password',
                  controller: _passwordController,
                  errorMessage: "Please enter your password",
                  obscureText: true,
                  inputBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 15,
                  bottom: 0,
                  child: Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordPage(),
                          ),
                        );
                      },
                      child: Text(
                        "Forgot?",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            CustomButton(
              label: "Login",
              isLoading: isLoading,
              backgroundColor: Colors.orangeAccent,
              fontSize: 14,
              fontWeight: FontWeight.normal,
              onPressed:
                  isLoading
                      ? null
                      : () async {
                        await signInWithEmailAndPassword();
                      },
            ),
            SizedBox(height: 40),
            Text("Sign up with"),
            SizedBox(height: 10),
            _signInScreen(),
            SizedBox(height: 40),
            _signupButton(),
          ],
        ),
      ),
    );
  }

  Widget _signupButton() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.95,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Dont have an account?"),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SignupPage()),
              );
            },
            child: Text("Create now"),
          ),
        ],
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
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Login successful!")),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                }
              }
            },
            child: Image.asset(
              "assets/images/google.webp",
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
              "assets/images/facebook.webp",
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
              "assets/images/twitter.webp",
              width: 30,
              height: 30,
            ),
          ),
        ],
      ),
    );
  }
}
