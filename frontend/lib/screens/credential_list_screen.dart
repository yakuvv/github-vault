import 'package:flutter/material.dart';
import '../models/credential.dart';
import '../services/api_service.dart';
import '../widgets/credential_card.dart';
import 'add_credential_screen.dart';
import 'settings_screen.dart';

class CredentialListScreen extends StatefulWidget {
  const CredentialListScreen({super.key});

  @override
  State<CredentialListScreen> createState() => _CredentialListScreenState();
}

class _CredentialListScreenState extends State<CredentialListScreen> {
  final ApiService _api = ApiService();
  List<Credential> _credentials = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _api.fetchCredentials('PAT'); // Default filter
      setState(() => _credentials = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vault"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _credentials.isEmpty
            ? const Center(child: Text("No credentials found"))
            : ListView.builder(
          itemCount: _credentials.length,
          itemBuilder: (context, index) => CredentialCard(cred: _credentials[index]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCredentialScreen())
        ).then((_) => _loadData()), // Reload when coming back
        child: const Icon(Icons.add),
      ),
    );
  }
}