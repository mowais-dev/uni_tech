import 'dart:ui';
import 'package:uni_tech/models/User.dart';
import 'package:uni_tech/partials/glass_container.dart';
import 'package:uni_tech/providers/auth_provider.dart';
import 'package:uni_tech/providers/navigation_provider.dart';
import 'package:uni_tech/styles/texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web/web.dart' as web;

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String validationError = "";
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void loginUser(WidgetRef ref) async {
    User? user = await getUserByEmail(emailController.text);

    if (!mounted) return;

    setState(() {
      if (user != null) {
        if (user.password == passwordController.text) {
          validationError = "";
          ref.read(authProvider.notifier).setAuth(user);
          web.window.localStorage.setItem(
            "token",
            encryptToken("${user.id} ${user.password}"),
          );
          if (ref.read(authProvider.notifier).getAuth() != null) {
            ref
                .read(navigationProvider.notifier)
                .setScreen(AppRoutes.dashboard);
          }
        } else {
          validationError = "Password does not match";
        }
      } else {
        validationError = "No user found with this email";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
          child: Center(
            child: GlassContainer(
              width: 450,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Uni Tech Login",
                    style: GoogleFonts.michroma(
                      color: kwhite,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    "Get best products at reasonable costs",
                    style: TextStyle(color: kmutedtext, fontSize: 12),
                  ),
                  SizedBox(height: 30),
                  TextField(
                    controller: emailController,
                    cursorColor: kwhite,
                    style: whiteText,
                    keyboardType: TextInputType.emailAddress,
                    decoration: inputDecoration("Email"),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    cursorColor: kwhite,
                    style: whiteText,
                    obscureText: true,
                    decoration: inputDecoration("Password"),
                  ),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (validationError != "")
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            validationError,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: primaryButton,
                          onPressed: () {
                            loginUser(ref);
                          },
                          child: Text("Login"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
