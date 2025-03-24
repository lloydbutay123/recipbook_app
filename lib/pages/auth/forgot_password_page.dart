import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recepies_app/widgets/custom_button.dart';
import 'package:recepies_app/widgets/custom_input_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: SafeArea(child: _buildUi()));
  }

  Widget _buildUi() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _forgotPasswordForm(),
          const SizedBox(height: 20),
          CustomButton(
            label: "Continue",
            isLoading: isLoading,
            backgroundColor: Colors.orangeAccent,
            fontSize: 14,
            fontWeight: FontWeight.normal,
            onPressed:
                isLoading
                    ? null
                    : () async {
                      await _resetPassword();
                    },
          ),
        ],
      ),
    );
  }

  Future<void> _resetPassword() async {
    String email = _emailController.text.trim();
    if (!formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    if (email.isEmpty) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter your email")));
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password reset email sent! Check your inbox."),
          ),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "An error occurred";

      if (e.code == "invalid-email") {
        errorMessage = "Invalid email format.";
      } else if (e.code == "user-not-found") {
        errorMessage = "No account found with this email.";
      } else if (e.code == "network-request-failed") {
        errorMessage = "Check your internet connection.";
      } else {
        errorMessage = "Error: ${e.message}";
      }

      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _forgotPasswordForm() {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Enter your email address",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Your email address will serve as backup and a login credential.",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 20),
          CustomInputField(
            label: "Email",
            controller: _emailController,
            errorMessage: "Please enter your email",
            inputBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
          ),
        ],
      ),
    );
  }
}
