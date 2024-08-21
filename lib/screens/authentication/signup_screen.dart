import 'dart:typed_data';

import 'package:car_go_pfe_lp_j2ee_driver/methods/auth_methods.dart';
import 'package:car_go_pfe_lp_j2ee_driver/methods/common_methods.dart';
import 'package:car_go_pfe_lp_j2ee_driver/providers/user_provider.dart';
import 'package:car_go_pfe_lp_j2ee_driver/screens/authentication/signin_screen.dart';
import 'package:car_go_pfe_lp_j2ee_driver/screens/dashboard.dart';
import 'package:car_go_pfe_lp_j2ee_driver/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _userphoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  Uint8List? _image;

  CommonMethods commonMethods = const CommonMethods();

  signUpFormValidation() {
    if (_usernameController.text.trim().length < 3) {
      commonMethods.displaySnackBar(
        'Username must be at least 3 characters long!',
        context,
      );
      return false;
    } else if (_userphoneController.text.trim().length < 10) {
      commonMethods.displaySnackBar(
        'Phone number must be at least 10 characters long!',
        context,
      );
      return false;
    } else if (!_emailController.text.contains('@') ||
        !_emailController.text.contains('.')) {
      commonMethods.displaySnackBar(
        'Invalid email address!',
        context,
      );
      return false;
    } else if (_passwordController.text.trim().length < 6) {
      commonMethods.displaySnackBar(
        'Password must be at least 6 characters long!',
        context,
      );
      return false;
    } else if (_passwordController.text != _confirmPasswordController.text) {
      commonMethods.displaySnackBar(
        'Passwords do not match!',
        context,
      );
      return false;
    } else if (_image == null) {
      commonMethods.displaySnackBar(
        'Please select a profile picture!',
        context,
      );
      return false;
    }
  }

  registerNewUser() async {
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const LoadingDialog(messageText: 'Creating account...'),
    );

    String res = await AuthMethods().signupUser(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      username: _usernameController.text.trim(),
      userphone: _userphoneController.text.trim(),
      file: _image!,
    );

    if (res != 'Success') {
      if (!context.mounted) return;
      Navigator.pop(context);
      commonMethods.displaySnackBar(res, context);
    } else {
      if (!context.mounted) return;
      await Provider.of<UserProvider>(context, listen: false).refreshUser();

      Navigator.pop(context);
      // commonMethods.displaySnackBar('Account created successfully!', context);
      // Navigate to home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const Dashboard(),
        ),
      );
    }
  }

  void selectImage() async {
    Uint8List im = await commonMethods.pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _usernameController.dispose();
    _userphoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void checkNetwork() async {
      // Check network connection
      await commonMethods.checkConnectivity(context);
    }

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
        ),
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Stack(
                    children: [
                      _image != null
                          ? CircleAvatar(
                              radius: 86,
                              backgroundImage: MemoryImage(_image!),
                            )
                          : const CircleAvatar(
                              radius: 86,
                              backgroundImage:
                                  AssetImage('assets/images/avatar_man.png'),
                            ),
                      Positioned(
                        bottom: -10,
                        left: 110,
                        child: IconButton(
                            onPressed: selectImage,
                            icon: const Icon(Icons.add_a_photo)),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Create a Driver\'s Account',
                  ),
                  // text fields
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      children: [
                        TextField(
                          controller: _usernameController,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            hintText: 'Enter your username',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _userphoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone number',
                            hintText: 'Enter your phone number',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your email',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _passwordController,
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _confirmPasswordController,
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Confirm password',
                            hintText: 'Confirm your password',
                          ),
                        ),
                        const SizedBox(height: 22),
                        ElevatedButton(
                          onPressed: () {
                            checkNetwork();
                            if (signUpFormValidation() == false) {
                              return;
                            }

                            registerNewUser();
                          },
                          child: const Text(
                            'Sign Up',
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account?',
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const SigninScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Sign In',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
