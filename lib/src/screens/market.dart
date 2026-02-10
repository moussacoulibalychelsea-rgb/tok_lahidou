import 'package:flutter/material.dart';
import 'package:tok_lahidou/src/services/product_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  final ProductService _service = ProductService();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _products = [];
  final Set<String> _liked = {};
  bool _loading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDoc;
  final Set<String> _ids = {}; // dedupe set

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 300) {
        if (!_loading) _loadMore();
      }
    });
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _loading) return;
    setState(() => _loading = true);
    final res = await _service.fetchProducts(startAfter: _lastDoc, limit: 10);
    final fetched = (res['products'] as List).cast<Map<String, dynamic>>();
    final last = res['lastDoc'] as DocumentSnapshot?;
    if (fetched.isEmpty) {
      setState(() {
        _hasMore = false;
        _loading = false;
      });
      return;
    }
    // append while deduping
    final newItems = <Map<String, dynamic>>[];
    for (final p in fetched) {
      final id = p['id']?.toString() ?? '';
      if (id.isEmpty) continue;
      if (_ids.contains(id)) continue;
      _ids.add(id);
      newItems.add(p);
    }
    setState(() {
      _products.addAll(newItems);
      _lastDoc = last;
      _loading = false;
    });

    // preload liked state for new items
    try {
      final uid = Firebase.apps.isEmpty ? 'demo' : (FirebaseAuth.instance.currentUser?.uid ?? 'demo');
      final ids = newItems.map((e) => e['id']?.toString() ?? '').where((s) => s.isNotEmpty).toList();
      if (ids.isNotEmpty) {
        final liked = await _service.fetchLikedIds(ids, uid);
        setState(() => _liked.addAll(liked));
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          floating: true,
          title: const Text('La Boutique', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            Stack(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.shopping_bag_outlined)),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Color(0xFFEA580C), shape: BoxShape.circle),
                    child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: ['Tout', 'Vêtements', 'Alimentation', 'Beauté', 'Artisanat', 'Autres']
                  .map((cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat),
                          onSelected: (val) {},
                          backgroundColor: Colors.white,
                          selectedColor: const Color(0x1AEA580C),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= _products.length) return const SizedBox.shrink();
                final p = _products[index];
                return _buildProductCardFromData(p);
              },
              childCount: _products.length,
            ),
          ),
        ),
        if (_loading) SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(vertical: 24), child: Center(child: CircularProgressIndicator())))
      ],
    );
  }

  Widget _buildProductCardFromData(Map<String, dynamic> p) {
    final images = (p['images'] as List?) ?? [];
    final image = images.isNotEmpty ? images.first.toString() : 'https://via.placeholder.com/400';
    final id = p['id']?.toString() ?? '';
    if (id.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<DocumentSnapshot>(
      stream: _service.productStream(id),
      builder: (context, snapshot) {
        final doc = snapshot.data;
        final data = (doc != null && doc.exists) ? (doc.data() as Map<String, dynamic>) : p;
        final likesCount = data['likesCount'] ?? 0;
        return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                image,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (c, e, s) => Container(color: Colors.grey[200], child: const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 40))),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p['title']?.toString() ?? 'Produit', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('${p['priceFCFA'] ?? '0'} FCFA', style: const TextStyle(color: Color(0xFFEA580C), fontWeight: FontWeight.bold)),
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
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    StreamBuilder<DocumentSnapshot>(
                        stream: _service.likeStream(id, Firebase.apps.isEmpty ? 'demo' : (FirebaseAuth.instance.currentUser?.uid ?? 'demo')),
                      builder: (ctx, likeSnap) {
                        final liked = likeSnap.data?.exists ?? _liked.contains(id);
                        return Row(
                          children: [
                            IconButton(
                              onPressed: () async {
                                final uid = Firebase.apps.isEmpty ? 'demo' : (FirebaseAuth.instance.currentUser?.uid ?? 'demo');
                                try {
                                  final newState = await _service.toggleLike(id, uid);
                                  if (!mounted) return;
                                  setState(() {
                                    if (newState) {
                                      _liked.add(id);
                                    } else {
                                      _liked.remove(id);
                                    }
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(newState ? 'Ajouté aux favoris' : 'Retiré des favoris')));
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur like: ${e.toString()}')));
                                }
                              },
                              icon: Icon(liked ? Icons.favorite : Icons.favorite_border, color: liked ? Colors.red : Colors.grey),
                            ),
                            Text(likesCount.toString()),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                TextButton(onPressed: () {}, child: const Text('Voir'))
              ],
            ),
          ),
        ],
      ),
        );
      },
    );
  }
}
