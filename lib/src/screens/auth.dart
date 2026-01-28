import 'package:flutter/material.dart';
import 'package:tok_lahidou/src/screens/main_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';


class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _logged = false;

  @override
  void initState() {
    super.initState();
  }

  void _onLogin() {
    setState(() {
      _logged = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_logged) return const MainNavigation();
    return AuthPage(onLogin: _onLogin);
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
  String _sentCode = '1234'; // simulated OTP (fallback)
  String? _verificationId;
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
    final fullPhone = phone.startsWith('+') ? phone : '+223$phone';
    setState(() => _isLoading = true);
    // If Firebase not initialized, immediately fallback to demo OTP mode.
    if (Firebase.apps.isEmpty) {
      setState(() {
        _isLoading = false;
        _step = 1;
        _sentCode = '1234';
      });
      return;
    }

    // Try Firebase phone verification; fallback to demo OTP if Firebase not configured or fails.
    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: fullPhone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          await FirebaseAuth.instance.signInWithCredential(credential);
          widget.onLogin();
        } catch (_) {}
      },
      verificationFailed: (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur envoi OTP: ${e.message}')));
        // fallback to demo
        setState(() {
          _step = 1;
          _sentCode = '1234';
        });
      },
      codeSent: (verificationId, resendToken) {
        setState(() {
          _isLoading = false;
          _verificationId = verificationId;
          _step = 1;
        });
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    ).catchError((e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      // fallback demo mode
      setState(() {
        _step = 1;
        _sentCode = '1234';
      });
    });
  }

  void _verifyOtp() {
    final code = _otpController.text.trim();
    if (_verificationId == null) {
      // fallback: accept demo code
      if (code == _sentCode) {
        widget.onLogin();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code incorrect')));
      }
      return;
    }
    // Verify with Firebase
    final credential = PhoneAuthProvider.credential(verificationId: _verificationId!, smsCode: code);
    setState(() => _isLoading = true);
    FirebaseAuth.instance.signInWithCredential(credential).then((_) {
      setState(() => _isLoading = false);
      widget.onLogin();
    }).catchError((e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Échec vérification: ${e.toString()}')));
    });
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
