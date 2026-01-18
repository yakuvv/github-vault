import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/crypto_service.dart';
import '../services/storage_service.dart';

class AddCredentialScreen extends StatefulWidget {
  const AddCredentialScreen({super.key});

  @override
  State<AddCredentialScreen> createState() => _AddCredentialScreenState();
}

class _AddCredentialScreenState extends State<AddCredentialScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _secretController = TextEditingController();
  String _selectedType = 'PAT';
  List<String> _selectedScopes = [];

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final storage = StorageService();
    final encryptionKey = await storage.getEncryptionKey();

    if (encryptionKey == null) return;

    // CLIENT-SIDE ENCRYPTION
    final encryptedValue = CryptoService.encryptSecret(
        _secretController.text,
        encryptionKey
    );

    try {
      // Send the encrypted blob to the API
      // await ApiService().postCredential(label: _labelController.text, encryptedValue: encryptedValue, ...);
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Credential")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: ['PAT', 'SSH', 'DEPLOY'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _selectedType = v!),
              decoration: const InputDecoration(labelText: "Type"),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _labelController,
              decoration: const InputDecoration(labelText: "Label (e.g., Production PAT)"),
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _secretController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Secret Value"),
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text("Encrypt & Save"),
            ),
          ],
        ),
      ),
    );
  }
}