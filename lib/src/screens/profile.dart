import 'package:flutter/material.dart';
import 'package:tok_lahidou/src/services/product_service.dart';
import 'package:tok_lahidou/src/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isFollowing = false;
  final ProductService _service = ProductService();
  final List<Map<String, dynamic>> _products = [];
  bool _loading = false;
  final UserService _userService = UserService();
  bool _isFollowingRemote = false;

  @override
  void initState() {
    super.initState();
    _loadSellerProducts();
    _checkFollowing();
  }

  Future<void> _checkFollowing() async {
    final uid = Firebase.apps.isEmpty ? 'demo' : (FirebaseAuth.instance.currentUser?.uid ?? 'demo');
    final isF = await _userService.isFollowing(sellerId: 'demo', userId: uid);
    setState(() => _isFollowingRemote = isF);
  }

  Future<void> _loadSellerProducts() async {
    if (!mounted) return;
    setState(() => _loading = true);
    // using 'demo' sellerId for demo users; replace with real uid when available
    final fetched = await _service.fetchProductsBySeller('demo');
    if (!mounted) return;
    setState(() {
      _products.clear();
      _products.addAll(fetched);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFFEA580C);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 46,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&q=80'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('@BazinBoutiqueBamako', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              SizedBox(height: 6),
                              Text('Boutique de textiles et accessoires', style: TextStyle(color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.more_vert),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildStat('Followers', '12.3k'),
                          const SizedBox(width: 12),
                          _buildStat('Suivis', '320'),
                          const SizedBox(width: 12),
                          _buildStat('Ventes', '1.2k'),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            Text('Découvrez nos nouvelles collections Bazin riche, livrées à Bamako et au-delà. Commandes par message.', style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final uid = Firebase.apps.isEmpty ? 'demo' : (FirebaseAuth.instance.currentUser?.uid ?? 'demo');
                      try {
                        final newState = await _userService.toggleFollow(sellerId: 'demo', userId: uid);
                        if (!mounted) return;
                        setState(() {
                          _isFollowing = newState;
                          _isFollowingRemote = newState;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(newState ? 'Vous suivez ce vendeur' : 'Vous ne suivez plus ce vendeur')));
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur follow: ${e.toString()}')));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFollowing ? Colors.grey.shade300 : accent,
                      foregroundColor: _isFollowing ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(_isFollowing ? 'Suivi' : 'Suivre', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: accent),
                    foregroundColor: accent,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            const Text('Produits en vedette', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            if (_loading) const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())),
            if (!_loading)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, i) {
                  final p = _products[i];
                  final images = (p['images'] as List?) ?? [];
                  final image = images.isNotEmpty ? images.first.toString() : 'https://via.placeholder.com/400';
                  final price = p['priceFCFA'] != null ? '${p['priceFCFA']} FCFA' : '—';
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                      boxShadow: [BoxShadow(color: const Color(0x08000000), blurRadius: 8)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.network(
                              image,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (c, e, s) => Container(
                                color: Colors.grey[200],
                                child: const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 40)),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p['title']?.toString() ?? 'Produit', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 6),
                              Text(price, style: TextStyle(color: accent, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: const Text('Ajouter', style: TextStyle(fontSize: 12)),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
