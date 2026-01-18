# GitHub Credential Vault

## Setup
1. Run `flutter pub get`.
2. Configure your backend URL in `lib/utils/constants.dart`.
3. For Desktop (Linux), ensure `libsecret-1-dev` is installed.

## Security
- **AES-256-GCM** ensures authenticated encryption.
- **Zero-Knowledge**: The backend never sees the plaintext secret or the encryption password.