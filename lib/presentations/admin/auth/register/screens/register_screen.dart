import 'package:barbershop2/presentations/admin/auth/login/screens/login_screen.dart';
import 'package:flutter/material.dart';
// import 'package:barbershop/screen/auth/login/service/screen/login_screen.dart';
// Import your AuthService and RegisterModel (RegistrationResponse)
import 'package:barbershop2/presentations/admin/auth/register/services/register_service.dart'; // Ensure this path is correct for your AuthService
import 'package:barbershop2/presentations/admin/auth/register/models/register_model.dart';
import 'package:go_router/go_router.dart'; // Ensure this path is correct for your model

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController(); // New controller for confirm password

  final AuthService _authService = AuthService(); // Use AuthService here
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword =
      true; // New state for confirm password visibility
  bool isLoading = false;

  void register() async {
    // Validate the form before proceeding
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true; // Indicate that loading is in progress
    });

    try {
      // Calling the API for registration
      final RegistrationResponse res = await _authService.registerUser(
        email: _emailController.text.trim(),
        name: _usernameController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation:
            _confirmPasswordController.text, // Pass confirm password
      );

      // Debug print for the entire response object
      debugPrint('Register Response: ${res.message}');
      debugPrint('Register Response Token: ${res.data.token}');
      debugPrint(
        'Register Response User: ${res.data.user.name}, ${res.data.user.email}',
      );

      // If we reach here, it means registerUser did not throw an exception, so it was successful
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registration successful!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ), // Navigate to LoginScreen
      );
    } catch (e) {
      // Catching any exception thrown by AuthService
      debugPrint(
        'Register Error: $e',
      ); // Use debugPrint for better logging in Flutter
      String errorMessage = e.toString().replaceFirst(
        'Exception: ',
        '',
      ); // Clean up 'Exception: ' prefix

      // Handle specific errors based on API message (if your API returns specific phrases)
      if (errorMessage.contains('email has already been taken')) {
        errorMessage = 'Email sudah terdaftar. Gunakan email lain.';
      } else if (errorMessage.contains(
        'password confirmation does not match',
      )) {
        errorMessage = 'Konfirmasi password tidak cocok.';
      }
      // Add more specific error message handling if needed

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        isLoading = false; // Indicate that loading is finished
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 90),
                  // Logo atau ikon barbershop
                  const Icon(
                    Icons.switch_access_shortcut_sharp,
                    size: 80,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'BOOKING',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'BARBERSHOP',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  // Full Name Input
                  TextFormField(
                    keyboardType: TextInputType.name,
                    controller: _usernameController,
                    validator: (val) => val == null || val.isEmpty
                        ? "Username wajib diisi"
                        : null,
                    decoration: const InputDecoration(
                      hintText: "Enter your full name",
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Email Input
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Email wajib diisi";
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(val)) {
                        return "Email tidak valid";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      hintText: "Enter your email address",
                      labelText: 'Email Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Password Input
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: (val) => val == null || val.length < 6
                        ? "Password minimal 6 karakter"
                        : null,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: "Enter your password",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Confirm Password Input (NEW)
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Konfirmasi password wajib diisi";
                      }
                      if (val != _passwordController.text) {
                        return "Password tidak cocok";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      hintText: "Re-enter your password",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Sign Up Button
                  SizedBox(
                    width:
                        370, // Consider using MediaQuery.of(context).size.width * 0.9 for responsiveness
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : register, // Disable button while loading
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 80,
                          vertical: 14,
                        ),
                        iconColor: Colors
                            .black, // This property doesn't directly apply to the button background
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Sign Up Link (Corrected to "Log In" Link)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(fontSize: 18),
                      ),
                      TextButton(
                        onPressed: () {
                          if (mounted) {
                            // Navigate to the registration screen, allowing the user to go back to login
                            context.push('/login');
                          }
                        },
                        child: const Text(
                          'Sign In',
                          style: TextStyle(color: Colors.black),
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
