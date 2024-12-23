import 'package:chatt3/components/my_buttton.dart';
import 'package:chatt3/services/auth/auth_service.dart';
import 'package:chatt3/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/my_text_field.dart';
import '../services/auth/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void signUp() async{
    if(passwordController.text != confirmPasswordController.text){
      ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(
          content: Text("Password do not match ")),);
      return;
    }
    final authService = Provider.of<AuthService>(context,listen: false);
    try{
      await authService.signUpWithEmailandPassword(emailController.text, passwordController.text,);

    }
    catch (e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()),),);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                // logo part
                Icon(
                  Icons.home,
                  size: 80,
                  color: Colors.blue,
                ),
                // Text part
                const SizedBox(height: 50),
                const Text(
                  "Create an account",
                  style: TextStyle(fontSize: 16),
                ),
                // email
                const SizedBox(height: 50),
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                // password
                const SizedBox(height: 50),
                MyTextField(
                  controller: passwordController, // Corrected controller for the password field
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 50),
                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),
                const SizedBox(height: 50),
                // sign-up button
                MyButton(onTap: signUp, text: "Sign Up"),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    const SizedBox(width: 4),
                    GestureDetector( // Fixed typo in 'GesterDetector'
                      onTap: widget.onTap, // Add appropriate functionality for login navigation
                      child: const Text(
                        'Login now',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
