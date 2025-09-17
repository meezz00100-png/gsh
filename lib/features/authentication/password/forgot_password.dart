import 'package:flutter/material.dart';
import 'package:harari_prosperity_app/routes/app_routes.dart';
import 'package:harari_prosperity_app/shared/widgets/custom_button.dart';
import 'package:harari_prosperity_app/shared/widgets/responsive_widgets.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password")),
      body: ResponsivePadding(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Reset Password?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "If you forget your password, you should follow this steps to reset you password.",
              ),
              const Divider(height: 40),
              const Text(
                "Enter Email Address",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: "example@gmail.com",
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: CustomButton(
                  text: "Next",
                  onPressed: () {},
                  filled: true,
                ),
              ),
              const SizedBox(height: 30),
              const Center(child: Text("If You Want To Create Another Account")),
              const SizedBox(height: 20),
              Center(
                child: CustomButton(
                  text: "Sign Up",
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
                  filled: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}