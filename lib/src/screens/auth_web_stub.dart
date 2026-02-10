import 'package:flutter/material.dart';
import 'package:tok_lahidou/src/screens/main_navigation.dart';

// Lightweight web-only auth stub that avoids firebase web packages.
// Provides the same widgets `AuthGate` and `AuthPage` used by the app,
// but operates in demo/offline mode only so the web build compiles.

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _logged = false;

  @override
  Widget build(BuildContext context) {
    if (_logged) return const MainNavigation();
    return AuthPage(onLogin: () => setState(() => _logged = true));
  }
}

class AuthPage extends StatefulWidget {
  final VoidCallback onLogin;
  const AuthPage({super.key, required this.onLogin});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  int _step = 0;
  String _sentCode = '1234';
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entrez un numéro de téléphone')));
      return;
    }
    setState(() => _isLoading = true);
    // Web stub: immediately fallback to demo OTP mode.
    setState(() {
      _isLoading = false;
      _step = 1;
      _sentCode = '1234';
    });
  }

  void _verifyOtp() {
    final code = _otpController.text.trim();
    if (code == _sentCode) {
      widget.onLogin();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code incorrect')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _step == 0 ? _buildPhoneStep() : _buildOtpStep(),
      ),
    );
  }

  Widget _buildPhoneStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Connexion par téléphone', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Numéro de téléphone', prefixText: '+223 '),
        ),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: _isLoading ? null : _sendOtp, child: _isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Envoyer le code')),
        const SizedBox(height: 12),
        TextButton(onPressed: () => widget.onLogin(), child: const Text('Se connecter en mode démo')),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Saisissez le code reçu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(controller: _otpController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Code')),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: _isLoading ? null : _verifyOtp, child: _isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Vérifier')),
        const SizedBox(height: 12),
        TextButton(onPressed: () => setState(() => _step = 0), child: const Text('Modifier le numéro')),
      ],
    );
  }
}
