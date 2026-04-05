import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _submit(AuthProvider provider) {
    if (_formKey.currentState!.validate()) {
      provider.signInOrSignUp(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: AppColors.background),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Text("Welcome to Talkism", style: AppTextStyles.h1),
                  const SizedBox(height: 8),
                  const Text(
                    "Enter your details to continue calling",
                    style: AppTextStyles.bodyM,
                  ),
                  const SizedBox(height: 48),
                  _buildField(
                    "Display Name",
                    _nameController,
                    Icons.person_outline,
                    validator: (v) => v!.isEmpty ? "Name is required" : null,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    "Email Address",
                    _emailController,
                    Icons.email_outlined,
                    validator: (v) {
                      if (v!.isEmpty) return "Email is required";
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                        return "Enter a valid email";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    "Password",
                    _passwordController,
                    Icons.lock_outline,
                    isPassword: true,
                    validator: (v) => v!.length < 6 ? "Password must be at least 6 chars" : null,
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: provider.isLoading ? null : () => _submit(provider),
                      child: provider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text("Continue"),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      "New users will be registered automatically",
                      style: AppTextStyles.bodyM,
                      textAlign: TextAlign.center,
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

  Widget _buildField(
    String hint,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hint,
          style: AppTextStyles.bodyM.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          style: AppTextStyles.bodyL,
          validator: validator,
          decoration: InputDecoration(
            hintText: "Enter your $hint",
            prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
          ),
        ),
      ],
    );
  }
}
