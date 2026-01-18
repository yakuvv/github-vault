import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/credential.dart';
import '../services/api_service.dart';
import '../services/crypto_service.dart';
import '../services/storage_service.dart';
import 'package:github_vault/services/api_service.dart';

class CredentialDetailScreen extends StatefulWidget {
  final Credential credential;
  const CredentialDetailScreen({required this.credential, super.key});

  @override
  State<CredentialDetailScreen> createState() => _CredentialDetailScreenState();
}

class _CredentialDetailScreenState extends State<CredentialDetailScreen> {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  String? _decryptedSecret;
  bool _isLoading = false;
  Timer? _clipboardTimer;

  Future<void> _handleReveal() async {
    setState(() => _isLoading = true);
    try {
      // 1. Fetch the encrypted blob from backend
      final encryptedBlob = await _api.revealSecret(widget.credential.id!);

      // 2. Get local encryption password
      final encryptionPassword = await _storage.getEncryptionKey();

      if (encryptionPassword != null) {
        // 3. Decrypt locally
        // The '??' provides an empty string if the value is null
        final decrypted = CryptoService.decryptSecret(encryptedBlob ?? '', encryptionPassword);
        setState(() => _decryptedSecret = decrypted);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Copied! Clipboard will clear in 30s.")),
    );

    // Security: Auto-clear clipboard after 30 seconds
    _clipboardTimer?.cancel();
    _clipboardTimer = Timer(const Duration(seconds: 30), () {
      Clipboard.setData(const ClipboardData(text: ''));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Clipboard cleared for security.")),
        );
      }
    });
  }

  @override
  void dispose() {
    _clipboardTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.credential.label)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow("Type", widget.credential.type),
            _buildInfoRow("Repository", widget.credential.repo ?? "All Repositories"),
            const Divider(height: 40, color: Colors.white24),
            const Text("Secret Value", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _decryptedSecret ?? "••••••••••••••••",
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 16),
                    ),
                  ),
                  if (_decryptedSecret == null)
                    IconButton(
                      icon: _isLoading ? const CircularProgressIndicator() : const Icon(Icons.visibility),
                      onPressed: _isLoading ? null : _handleReveal,
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () => _copyToClipboard(_decryptedSecret!),
                    ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.1)),
                onPressed: () => _confirmDelete(),
                child: const Text("Delete Credential", style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await _api.deleteCredential(widget.credential.id!);
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // return to list
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}