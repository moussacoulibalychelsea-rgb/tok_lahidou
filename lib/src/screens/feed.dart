import 'package:flutter/material.dart';
import 'package:tok_lahidou/src/widgets/video_player_item.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final List<Map<String, String>> _media = [
  {'type': 'video', 'url': 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4'},
    {'type': 'video', 'url': 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'},
    {'type': 'video', 'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4'},
    {'type': 'video', 'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4'},
    {'type': 'video', 'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4'},
    // Ajouts fiables supplémentaires
    {'type': 'video', 'url': 'https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4'},
    {'type': 'video', 'url': 'https://storage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4'},
    // Exemples d'images pour fallback / variété
    {'type': 'image', 'url': 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&q=80'},
    {'type': 'image', 'url': 'https://images.unsplash.com/photo-1547949003-9792a18a2601?auto=format&fit=crop&q=80'},
  ];

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: _media.length,
      itemBuilder: (context, index) {
        final item = _media[index];
        final isVideo = item['type'] == 'video';
        return Stack(
          fit: StackFit.expand,
          children: [
            // Background: image or video
            Container(
              color: Colors.black,
              child: isVideo
                  ? VideoPlayerItem(url: item['url']!)
                  : Image.network(
                      item['url']!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.white54, size: 64),
                        ),
                      ),
                    ),
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, const Color(0xB3000000)],
                ),
              ),
            ),
            // Actions (Right side)
            Positioned(
              right: 16,
              bottom: 120,
              child: Column(
                children: [
                  _buildActionButton(Icons.favorite, '12k'),
                  const SizedBox(height: 20),
                  _buildActionButton(Icons.comment, '450'),
                  const SizedBox(height: 20),
                  _buildActionButton(Icons.share, 'Partager'),
                ],
              ),
            ),
            // Info & Product (Bottom)
            Positioned(
              left: 16,
              right: 80,
              bottom: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '@BazinBoutiqueBamako',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Nouveautés Bazin Riche pour la fête ! 🌟 #Bamako #Bazin',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEA580C),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.shopping_bag, color: Colors.white, size: 20),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ACHETER', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                                Text('Bazin Riche 5m', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        const Text('45.000 FCFA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.black38,
          radius: 26,
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
