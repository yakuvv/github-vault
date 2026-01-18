class Credential {
  final String? id;
  final String type; // PAT, SSH, DEPLOY
  final String label;
  final String? encryptedValue;
  final List<String> scopes;
  final String? repo;
  final DateTime? expiresAt;

  Credential({
    this.id,
    required this.type,
    required this.label,
    this.encryptedValue,
    required this.scopes,
    this.repo,
    this.expiresAt,
  });

  factory Credential.fromJson(Map<String, dynamic> json) {
    return Credential(
      id: json['id'],
      type: json['type'],
      label: json['label'],
      encryptedValue: json['encryptedValue'],
      scopes: List<String>.from(json['scopes'] ?? []),
      repo: json['repo'],
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    );
  }
}