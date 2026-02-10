import 'package:flutter/material.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Portefeuille Doni', style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFEA580C), Color(0xFFC2410C)]),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [BoxShadow(color: const Color(0x4DEA580C), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Solde DoniCoins', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0x33FFFFFF), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.wallet, color: Colors.white),
                    ),
                  ],
                ),
                const Text('25.400 DC', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add),
                        label: const Text('Recharger'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFEA580C)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.call_made),
                        label: const Text('Retrait'),
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white38)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Transactions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text('Voir tout', style: TextStyle(color: Color(0xFFEA580C), fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          _buildTransactionItem('Achat Bazin', '-45.000 DC', 'Aujourd\'hui', false),
          _buildTransactionItem('Dépôt Orange Money', '+50.000 DC', 'Hier', true),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(String title, String amount, String date, bool isCredit) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: isCredit ? Colors.green.shade50 : Colors.red.shade50,
        child: Icon(isCredit ? Icons.arrow_downward : Icons.arrow_upward, color: isCredit ? Colors.green : Colors.red, size: 18),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      trailing: Text(amount, style: TextStyle(fontWeight: FontWeight.bold, color: isCredit ? Colors.green : Colors.black87)),
    );
  }
}
