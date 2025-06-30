import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test1/core/routes/routes.dart';
import 'package:test1/core/utils/extension.dart';
import 'package:test1/core/widget/custom_text_field.dart';
import 'package:test1/core/widget/google_button.dart';
import 'package:test1/core/widget/snakbar_widget.dart';
import 'package:test1/feature/auth/logic/cubit/auth_cubit.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> signInWithFacebook1() async {
    try {
      print("00---------------- ");
      // Trigger Facebook login
      final LoginResult result = await FacebookAuth.instance.login();
      print("11---------------- ");
      if (result.status == LoginStatus.success) {
        // Get the access token
        final AccessToken accessToken = result.accessToken!;
        print("2 ---------------- ${accessToken}");
        // Create a credential for Firebase
        final OAuthCredential credential = FacebookAuthProvider.credential(
          accessToken.tokenString,
        );
        // Sign in to Firebase with the credential
        await FirebaseAuth.instance.signInWithCredential(credential);
        print("33---------------- ");
      } else {
        print('Facebook login failed: ${result.status}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> logout() async {
    await FacebookAuth.instance.logOut();
    print('---DN');
  }

  // Future<UserCredential> signInWithFacebook() async {
  //   try {
  //     final LoginResult loginResult = await FacebookAuth.instance.login();
  //     if (loginResult.status == LoginStatus.success) {
  //       final String accessToken = loginResult.accessToken!.tokenString;
  //       final OAuthCredential facebookAuthCredential =
  //           FacebookAuthProvider.credential(accessToken);
  //       return await FirebaseAuth.instance.signInWithCredential(
  //         facebookAuthCredential,
  //       );
  //     } else {
  //       throw Exception("Facebook login failed: ${loginResult.status}");
  //     }
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              showError(context, state.message, Colors.red);
            } else if (state is AuthSuccess) {
              context.pushReplacementNamed(Routes.homeScreen);
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0766ff),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 60),

                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock_outlined,
                    isPassword: true,
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          isLoading
                              ? null
                              : () {
                                final email = _emailController.text.trim();
                                final password =
                                    _passwordController.text.trim();

                                if (email.isEmpty || password.isEmpty) {
                                  showError(
                                    context,
                                    'Please fill all fields',
                                    Colors.orange,
                                  );
                                  return;
                                }

                                context.read<AuthCubit>().loginWithEmail(
                                  email: email,
                                  password: password,
                                );
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0766ff),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child:
                          isLoading
                              ? const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              )
                              : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'OR',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 20),

                  GoogleButton(
                    isloading: isLoading,
                    photo: 'assets/googleLogo.png',
                    onPressed: () {
                      context.read<AuthCubit>().signInWithGoogle();
                    },
                    text: 'Login with Google',
                  ),
                  const SizedBox(height: 20),

                  GoogleButton(
                    isloading: isLoading,
                    photo: "assets/facebookLogo.webp",
                    onPressed: () async {
                      // await logout();
                      await context.read<AuthCubit>().signInWithFacebook();
                    },
                    text: 'Login with Facebook',
                  ),

                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.pushReplacementNamed(Routes.signupScreen);
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Color(0xff0766ff),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
