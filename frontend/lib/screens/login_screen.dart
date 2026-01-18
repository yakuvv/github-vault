import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _encryptionController = TextEditingController();
  bool _isNewUser = false; // Toggle this based on if storage has an encryption key
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    final key = await StorageService().getEncryptionKey();
    setState(() => _isNewUser = (key == null));
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      final auth = Provider.of<AuthService>(context, listen: false);

      // 1. Authenticate with backend
      bool success = await auth.login(
          _usernameController.text,
          _passwordController.text
      );

      if (success && _isNewUser) {
        // 2. Save encryption key locally if first time
        if (_encryptionController.text.length < 8) {
          throw Exception("Encryption password must be at least 8 characters");
        }
        await StorageService().saveEncryptionKey(_encryptionController.text);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 80, color: Color(0xFF238636)),
              const SizedBox(height: 24),
              const Text("GitHub Vault", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 48),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Username", prefixIcon: Icon(Icons.person)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.password)),
              ),
              if (_isNewUser) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _encryptionController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: "Setup Encryption Password",
                      helperText: "This key never leaves your device and is used to decrypt secrets.",
                      prefixIcon: Icon(Icons.security)
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading ? const CircularProgressIndicator() : const Text("Sign In"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}