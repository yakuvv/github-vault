import 'package:flutter/material.dart';
import '../models/credential.dart';
import '../screens/credential_detail_screen.dart';

class CredentialCard extends StatelessWidget {
  final Credential cred;

  const CredentialCard({required this.cred, super.key});

  Color _getExpiryColor() {
    if (cred.expiresAt == null) return Colors.grey;
    final daysRemaining = cred.expiresAt!.difference(DateTime.now()).inDays;

    if (daysRemaining < 0) return Colors.red;
    if (daysRemaining < 30) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final expiryColor = _getExpiryColor();

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF30363D), width: 1),
      ),
      color: const Color(0xFF161B22),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: expiryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getTypeIcon(cred.type),
            color: expiryColor,
          ),
        ),
        title: Text(
          cred.label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFC9D1D9),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${cred.type} • ${cred.repo ?? 'All Repos'}",
              style: const TextStyle(color: Colors.grey),
            ),
            if (cred.expiresAt != null)
              Padding(
                // FIXED LINE BELOW
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  "Expires: ${cred.expiresAt!.toLocal().toString().split(' ')[0]}",
                  style: TextStyle(color: expiryColor, fontSize: 12),
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CredentialDetailScreen(credential: cred),
            ),
          );
        },
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'PAT': return Icons.vpn_key_outlined;
      case 'SSH': return Icons.terminal_outlined;
      case 'DEPLOY': return Icons.cloud_upload_outlined;
      default: return Icons.security;
    }
  }
}