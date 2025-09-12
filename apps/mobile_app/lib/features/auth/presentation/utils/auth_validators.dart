class AuthValidators {
  static String? email(String? v) {
    if (v == null || v.isEmpty) return 'Write email';
    if (!v.contains('@')) return 'Incorrect email';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Write password';
    if (v.length < 6) return 'Min 6 characters';
    return null;
  }

  static String? confirm(String? confirm, String original) {
    if (confirm == null || confirm.isEmpty) return 'Repeat password please';
    if (confirm != original) return 'Passwords do not match';
    return null;
  }
}
