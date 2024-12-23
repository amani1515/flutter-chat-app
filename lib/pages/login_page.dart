import 'package:chatt3/components/my_buttton.dart';
import 'package:chatt3/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:chatt3/components/my_text_field.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap; // Fixed this line by adding a name to the final variable
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Text controller
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signIn() async {
    // get auth service
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.signInWithEmailAndPassword(
        emailController.text,
        passwordController.text,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()), // Fixed missing comma
        ),
      );
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
                  "Welcome!",
                  style: TextStyle(fontSize: 16), // Fixed typo in "Well come!" to "Welcome!"
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
                  controller: passwordController, // Corrected the controller for the password field
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 50),
                // sign in button
                MyButton(onTap: signIn, text: "Sign in"),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Not a member?'),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap, // Corrected to call the widget's onTap
                      child: const Text(
                        'Register now',
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
