import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../../main.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late final EmailAuthController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EmailAuthController(
      client: client,
      startScreen: EmailFlowScreen.login,
      onAuthenticated: () {
        // Session is automatically registered!
        // Router will handle redirect automatically
      },
      onError: (error) {
        setState(() {}); // Rebuild to show error
      },
    );
    // Listen to controller state changes
    _controller.addListener(_onControllerStateChanged);
  }

  void _onControllerStateChanged() {
    setState(() {}); // Rebuild UI when controller state changes
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerStateChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleAction() async {
    switch (_controller.currentScreen) {
      case EmailFlowScreen.login:
        await _controller.login();
        break;
      case EmailFlowScreen.startRegistration:
        await _controller.startRegistration();
        break;
      case EmailFlowScreen.verifyRegistration:
        await _controller.verifyRegistrationCode();
        break;
      case EmailFlowScreen.completeRegistration:
        await _controller.finishRegistration();
        break;
      default:
        break;
    }
  }

  String _getTitleForScreen(EmailFlowScreen screen) {
    switch (screen) {
      case EmailFlowScreen.login:
        return 'Welcome Back';
      case EmailFlowScreen.startRegistration:
        return 'Create Account';
      case EmailFlowScreen.verifyRegistration:
        return 'Verify Email';
      case EmailFlowScreen.completeRegistration:
        return 'Set Password';
      default:
        return 'Authentication';
    }
  }

  String _getButtonTextForScreen(EmailFlowScreen screen) {
    switch (screen) {
      case EmailFlowScreen.login:
        return 'Sign In';
      case EmailFlowScreen.startRegistration:
        return 'Send Code';
      case EmailFlowScreen.verifyRegistration:
        return 'Verify';
      case EmailFlowScreen.completeRegistration:
        return 'Complete Registration';
      default:
        return 'Continue';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentScreen = _controller.currentScreen;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.lock_person_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 32),
                Text(
                  _getTitleForScreen(currentScreen),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Error message
                if (_controller.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _controller.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Email field (login & signup start)
                if (currentScreen == EmailFlowScreen.login ||
                    currentScreen == EmailFlowScreen.startRegistration)
                  TextField(
                    controller: _controller.emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_controller.isLoading,
                  ),

                // Password field (login & complete registration)
                if (currentScreen == EmailFlowScreen.login ||
                    currentScreen == EmailFlowScreen.completeRegistration) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller.passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.key_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    obscureText: true,
                    enabled: !_controller.isLoading,
                    onSubmitted: (_) => _handleAction(),
                  ),
                ],

                // Verification code field
                if (currentScreen == EmailFlowScreen.verifyRegistration)
                  TextField(
                    controller: _controller.verificationCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Verification Code',
                      prefixIcon: Icon(Icons.numbers),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    enabled: !_controller.isLoading,
                    onSubmitted: (_) => _handleAction(),
                  ),

                const SizedBox(height: 32),

                // Action button
                FilledButton(
                  onPressed: _controller.isLoading ? null : _handleAction,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _controller.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _getButtonTextForScreen(currentScreen),
                          style: const TextStyle(fontSize: 16),
                        ),
                ),

                const SizedBox(height: 24),

                // Toggle between login/signup
                if (currentScreen == EmailFlowScreen.login)
                  TextButton(
                    onPressed: () => _controller.navigateTo(
                      EmailFlowScreen.startRegistration,
                    ),
                    child: const Text("Don't have an account? Sign Up"),
                  ),

                // Back button for non-login screens
                if (currentScreen != EmailFlowScreen.login &&
                    _controller.canNavigateBack)
                  TextButton(
                    onPressed: () => _controller.navigateBack(),
                    child: const Text('Back to Sign In'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
