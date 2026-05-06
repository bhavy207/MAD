import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/user_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final result = await ref.read(userProvider.notifier).login(
      emailOrName: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    switch (result) {
      case LoginResult.success:
        context.go('/home');
        break;

      case LoginResult.noAccountFound:
        // Show dialog offering to sign up
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.person_search, color: AppColors.warning),
                SizedBox(width: 8),
                Text("No Account Found"),
              ],
            ),
            content: const Text(
              "We couldn't find an account with that name or mobile number.\n\n"
              "This can happen if you used the app before but haven't registered yet. "
              "Would you like to create a new account?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Try Again"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/signup');
                },
                child: const Text("Sign Up"),
              ),
            ],
          ),
        );
        break;

      case LoginResult.wrongPassword:
        // Show wrong password snackbar with reset option
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Wrong password. Please try again.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            action: SnackBarAction(
              label: 'Reset',
              textColor: Colors.white,
              onPressed: _showResetDialog,
            ),
          ),
        );
        break;
    }
  }

  // ── Reset / re-register dialog ────────────────────────────────────────────
  Future<void> _showResetDialog() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.restart_alt, color: AppColors.error),
            SizedBox(width: 8),
            Text("Reset Account"),
          ],
        ),
        content: const Text(
          "This will clear the saved account so you can register again.\n\n"
          "⚠️ Your appointments data will not be deleted.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Reset & Sign Up", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (ok == true && mounted) {
      await ref.read(userProvider.notifier).clearAccount();
      context.go('/signup');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.backgroundLight, Colors.indigo.shade50],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.queue_rounded, size: 80, color: AppColors.primary),
                    const SizedBox(height: 16),
                    const Text(
                      "SmartQueue",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Precision waiting for modern business.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 48),
                    Card(
                      elevation: 8,
                      shadowColor: AppColors.primary.withOpacity(0.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              "Welcome back",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Sign in to manage your appointments.",
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 24),

                            // ── Identifier field ─────────────────────────
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                labelText: "Name, Mobile or Email",
                                hintText: "Enter the name/mobile used at sign up",
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Please enter your name or mobile'
                                  : null,
                            ),
                            const SizedBox(height: 16),

                            // ── Password field ───────────────────────────
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: "Password",
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () =>
                                      setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Please enter your password' : null,
                            ),
                            const SizedBox(height: 16),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Switch(
                                      value: _rememberMe,
                                      onChanged: (v) =>
                                          setState(() => _rememberMe = v),
                                      activeColor: AppColors.primary,
                                    ),
                                    const Text("Remember me",
                                        style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                                TextButton(
                                  onPressed: _showResetDialog,
                                  child: const Text("Forgot password?",
                                      style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // ── Login button ─────────────────────────────
                            ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text("Login",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 16),

                            // ── Guest button ─────────────────────────────
                            OutlinedButton(
                              onPressed: () => context.go('/home'),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                side:
                                    const BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text("Continue as Guest"),
                            ),
                            const SizedBox(height: 16),

                            // ── Sign Up link ─────────────────────────────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Don't have an account?"),
                                TextButton(
                                  onPressed: () => context.go('/signup'),
                                  child: const Text("Sign Up"),
                                ),
                              ],
                            ),

                            // ── Admin hint ───────────────────────────────
                            const Divider(height: 24),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.indigo.shade100),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.admin_panel_settings_outlined,
                                      size: 16, color: Colors.indigo),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Admin: admin@smartqueue.com / admin123",
                                      style: TextStyle(
                                          fontSize: 11, color: Colors.indigo),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
