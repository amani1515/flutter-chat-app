import 'package:chatt3/services/auth/login_or_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../pages/home_page.dart';
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context,snapshot){
// if loged in
          if(snapshot.hasData){
            return const HomePage();
          }
          // if not
            else{
              return const LoginOrRegister();
          }
          },
      ),
    );
  }
}
