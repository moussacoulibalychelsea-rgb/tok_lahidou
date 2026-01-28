import 'package:flutter/material.dart';
import 'package:tok_lahidou/src/screens/feed.dart';
import 'package:tok_lahidou/src/screens/market.dart';
import 'package:tok_lahidou/src/screens/wallet.dart';
import 'package:tok_lahidou/src/screens/profile.dart';
import 'package:tok_lahidou/src/widgets/publish_modal.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    FeedPage(),
    const MarketPage(),
    const SizedBox(), // Placeholder for Publish
    const WalletPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      _showPublishModal();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showPublishModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => const PublishModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFEA580C),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Boutique'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: 'Publier'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Doni'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}
