import 'package:butler_client/butler_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:serverpod_auth_client/module.dart';

import '../../main.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

enum AuthMode { login, signupEmail, signupVerify, signupPassword }

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(); // Used for login & setting new password
  final _codeController = TextEditingController();
  final _nameController = TextEditingController(); // Optional: if we want to update name later

  AuthMode _mode = AuthMode.login;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Signup State
  UuidValue? _accountRequestId;
  String? _verificationToken;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleAuthAction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      switch (_mode) {
        case AuthMode.login:
          await _performLogin();
          break;
        case AuthMode.signupEmail:
          await _performSignupStart();
          break;
        case AuthMode.signupVerify:
          await _performVerifyCode();
          break;
        case AuthMode.signupPassword:
          await _performFinishSignup();
          break;
      }
    } catch (e) {
      debugPrint('Auth Error: $e'); // Print to console for debugging
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _performLogin() async {
    final result = await client.emailIdp.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    
    final Map<String, dynamic> data = result.toJson();
    debugPrint('AuthLogin Result: $data');

    // Fallback for property names
    final userInfoData = data['userInfo'] ?? data['user'];
    final keyId = data['keyId'] ?? data['id'];
    final key = data['key'] ?? data['token'];
    final authUserId = data['authUserId'];

    if (userInfoData != null && keyId != null && key != null) {
      final userInfo = UserInfo.fromJson(userInfoData);
      
       await (client.auth as dynamic).registerSignedInUser(
        userInfo,
        keyId,
        key,
      );
    } else if (authUserId != null && key != null) {
      debugPrint('Constructing manual session for UUID: $authUserId');
      final int placeholderKeyId = 0; 

      final userInfo = UserInfo(
        id: placeholderKeyId, 
        userIdentifier: authUserId,
        userName: _emailController.text.split('@').first, 
        created: DateTime.now(),
        scopeNames: [],
        blocked: false,
        email: _emailController.text,
      );

      await (client.auth as dynamic).registerSignedInUser(
        userInfo,
        placeholderKeyId,
        key,
      );
    } else {
       throw Exception('Login failed: Incomplete response data');
    }
  }

  Future<void> _performSignupStart() async {
    final result = await client.emailIdp.startRegistration(
      email: _emailController.text.trim(),
    );
    // result is UuidValue (accountRequestId)
    setState(() {
      _accountRequestId = result;
      _mode = AuthMode.signupVerify;
    });
  }

  Future<void> _performVerifyCode() async {
    if (_accountRequestId == null) return;
    
    final result = await client.emailIdp.verifyRegistrationCode(
      accountRequestId: _accountRequestId!,
      verificationCode: _codeController.text.trim(),
    );
    
    // result is verificationToken (String)
    setState(() {
      _verificationToken = result;
      _mode = AuthMode.signupPassword;
    });
  }

  Future<void> _performFinishSignup() async {
    if (_verificationToken == null) return;

    final result = await client.emailIdp.finishRegistration(
      registrationToken: _verificationToken!,
      password: _passwordController.text,
    );

    final Map<String, dynamic> data = result.toJson();
     debugPrint('AuthSignup Result: $data');

    // Fallback for property names
    final userInfoData = data['userInfo'] ?? data['user'];
    final keyId = data['keyId'] ?? data['id'];
    final key = data['key'] ?? data['token'];
    final authUserId = data['authUserId']; // UUID from server

    if (userInfoData != null && keyId != null && key != null) {
       final userInfo = UserInfo.fromJson(userInfoData);

       await (client.auth as dynamic).registerSignedInUser(
        userInfo,
        keyId,
        key,
      );
    } else if (authUserId != null && key != null) {
      // Manual Session Construction for JWT/UUID backend where UserInfo is missing in response
      debugPrint('Constructing manual session for UUID: $authUserId');
      
      // We must provide an Int keyId for the legacy Flutter session manager signature,
      // even if the server uses UUIDs. The actual authentication relies on the 'key' (JWT).
      // We use 0 or hashcode as a placeholder.
      final int placeholderKeyId = 0; 

      final userInfo = UserInfo(
        id: placeholderKeyId, 
        userIdentifier: authUserId, // Passing UUID as identifier
        userName: _emailController.text.split('@').first, // Best guess
        created: DateTime.now(),
        scopeNames: [],
        blocked: false,
        email: _emailController.text,
      );

      await (client.auth as dynamic).registerSignedInUser(
        userInfo,
        placeholderKeyId,
        key,
      );
    } else {
       throw Exception('Registration failed: Incomplete data');
    }
  }

  void _switchMode(AuthMode mode) {
    setState(() {
      _mode = mode;
      _errorMessage = null;
      _formKey.currentState?.reset();
    });
  }

  String get _title {
    switch (_mode) {
      case AuthMode.login: return 'Welcome Back';
      case AuthMode.signupEmail: return 'Create Account';
      case AuthMode.signupVerify: return 'Verify Email';
      case AuthMode.signupPassword: return 'Set Password';
    }
  }

  String get _buttonText {
    switch (_mode) {
      case AuthMode.login: return 'Sign In';
      case AuthMode.signupEmail: return 'Send Code';
      case AuthMode.signupVerify: return 'Verify';
      case AuthMode.signupPassword: return 'Complete Registration';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
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
                    _title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (_mode == AuthMode.login || _mode == AuthMode.signupEmail)
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value != null && value.contains('@') ? null : 'Enter a valid email',
                    ),
                  
                  if (_mode == AuthMode.login || _mode == AuthMode.signupPassword) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.key_outlined),
                         border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                      obscureText: true,
                      validator: (value) => value != null && value.length >= 8 ? null : 'Password must be at least 8 characters',
                    ),
                  ],

                   if (_mode == AuthMode.signupVerify)
                    TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Verification Code',
                        prefixIcon: Icon(Icons.numbers),
                         border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value != null && value.isNotEmpty ? null : 'Enter current code',
                    ),

                  const SizedBox(height: 32),
                  
                  FilledButton(
                    onPressed: _isLoading ? null : _handleAuthAction,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(_buttonText, style: const TextStyle(fontSize: 16)),
                  ),

                  const SizedBox(height: 24),

                  if (_mode == AuthMode.login)
                    TextButton(
                      onPressed: () => _switchMode(AuthMode.signupEmail),
                      child: const Text("Don't have an account? Sign Up"),
                    ),
                  
                   if (_mode != AuthMode.login)
                    TextButton(
                      onPressed: () => _switchMode(AuthMode.login),
                      child: const Text("Already have an account? Sign In"),
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
