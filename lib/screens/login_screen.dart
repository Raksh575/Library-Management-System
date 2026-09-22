import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  List<dynamic> _users = [];
  // Dev helper: set to true to ignore 10-min expiry during testing
  static const bool _ignoreExpiry = true;

  // Admin credentials (in real app, this should be in a secure backend)
  final String _adminEmail = "admin@mcet.in";
  final String _adminPassword = "admin123";

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users');
    if (!mounted) return;
    setState(() {
      _users = usersJson != null && usersJson.isNotEmpty
          ? (jsonDecode(usersJson) as List<dynamic>)
          : <dynamic>[];
    });
  }

  Future<void> _resetAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('users');
    // Legacy keys (cleanup only)
    await prefs.remove('name');
    await prefs.remove('email');
    await prefs.remove('password');
    await prefs.remove('registeredAtMs');
    await prefs.remove('validUntilMs');
    await _loadUsers();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved accounts reset. Please register again.')),
    );
  }

  Future<void> _quickLogin(Map<String, dynamic> user) async {
    _emailController.text = (user['email'] ?? '').toString();
    _passwordController.text = (user['password'] ?? '').toString();
    if (!_isLoading) {
      await _login();
    }
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final emailLower = email.toLowerCase();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both email and password")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Check if admin login
    if (emailLower == _adminEmail && password == _adminPassword) {
      // Navigate to admin dashboard
      await Future.delayed(const Duration(milliseconds: 1000));
      Navigator.pushReplacementNamed(context, '/admin');
      return;
    }

    // Check student login against users list
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users');
    final List<dynamic> users = usersJson != null && usersJson.isNotEmpty
        ? (jsonDecode(usersJson) as List<dynamic>)
        : <dynamic>[];
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    Map<String, dynamic>? matched;
    for (final u in users) {
      if (u is Map) {
        final uEmail = (u['email'] ?? '').toString();
        final uEmailLower = uEmail.toLowerCase();
        final uPass = (u['password'] ?? '').toString();
        if (uEmailLower == emailLower && uPass == password) {
          matched = u.map((k, v) => MapEntry(k.toString(), v));
          break;
        }
      }
    }

    if (matched != null) {
      final int? validUntilMs = matched['validUntilMs'] is int ? matched['validUntilMs'] as int : int.tryParse('${matched['validUntilMs']}');
      if (!_ignoreExpiry && validUntilMs != null && nowMs > validUntilMs) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration expired. Please register again.")),
        );
        setState(() { _isLoading = false; });
        return;
      }
      // Persist the logged-in user's basic info for app header/drawer
      await prefs.setString('name', (matched['name'] ?? '').toString());
      await prefs.setString('email', (matched['email'] ?? '').toString());
      await Future.delayed(const Duration(milliseconds: 1000));
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Fallback: support legacy single savedEmail/password keys
      final legacyEmail = prefs.getString('email');
      final legacyPassword = prefs.getString('password');
      final legacyValidUntil = prefs.getInt('validUntilMs');
      final legacyMatch = (legacyEmail?.toLowerCase() == emailLower) && legacyPassword == password;

      if (legacyMatch) {
        if (!_ignoreExpiry && legacyValidUntil != null && nowMs > legacyValidUntil) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Registration expired. Please register again.")),
          );
          setState(() { _isLoading = false; });
          return;
        }
        // Ensure legacy login still sets name/email for header display
        final legacyName = prefs.getString('name') ?? 'Student';
        await prefs.setString('name', legacyName);
        await prefs.setString('email', legacyEmail ?? '');
        await Future.delayed(const Duration(milliseconds: 1000));
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        if (_users.isEmpty && (users.isEmpty)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No accounts found. Please register first.")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid email or password")),
          );
        }
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER ---
            Container(
              height: 280,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3A7BD5), Color(0xFF00D2FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.library_books, size: 80, color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      "MCET College Library",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Student & Admin Portal",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // --- LOGIN FORM ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      if (!_isLoading) {
                        _login();
                      }
                    },
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text("Login", style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: Text(
                      "Don't have an account? Register",
                      style: GoogleFonts.poppins(color: Colors.indigo),
                    ),
                  ),
                ],
              ),
            ),

            // Demo Credentials Info
            Container(
              margin: const EdgeInsets.only(top: 30),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Demo Credentials:",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Admin: admin@mcet.in / admin123",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    "Student: Register first, then login",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const SizedBox.shrink()
                ],
              ),
            ),
            // Switch Account (saved users)
            if (_users.isNotEmpty) ...[
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Switch account",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final u = (_users[index] as Map).map((k, v) => MapEntry(k.toString(), v));
                  final name = (u['name'] ?? '').toString();
                  final email = (u['email'] ?? '').toString();
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: const Icon(Icons.account_circle, color: Colors.indigo),
                      title: Text(name.isEmpty ? email : name),
                      subtitle: Text(email),
                      trailing: TextButton(
                        onPressed: () => _quickLogin(u),
                        child: const Text('Login'),
                      ),
                      onTap: () => _quickLogin(u),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}