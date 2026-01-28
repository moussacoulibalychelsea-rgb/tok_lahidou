import 'package:flutter/material.dart';
import 'package:tok_lahidou/src/screens/add_product.dart';

class PublishModal extends StatelessWidget {
  const PublishModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Créer du contenu', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 32),
          _buildPublishOption(
            Icons.video_library,
            'Publier une vidéo',
            'Montrez vos produits en mouvement',
            const Color(0xFFEA580C),
          ),
          const SizedBox(height: 20),
          _buildPublishOption(
            Icons.add_shopping_cart,
            'Ajouter un produit',
            'Mettez à jour votre inventaire',
            Colors.black87,
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPublishOption(IconData icon, String title, String sub, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200, width: 2),
        ),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: color, radius: 28, child: Icon(icon, color: Colors.white, size: 30)),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(sub, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
