import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoPlayerItem extends StatefulWidget {
  final String url;
  const VideoPlayerItem({super.key, required this.url});

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      // Try to set crossOrigin on any existing video elements (helps CORS on web)
      try {
        final vids = html.document.getElementsByTagName('video');
        if (vids.isNotEmpty) {
          final v = vids.last as html.VideoElement;
          v.crossOrigin = 'anonymous';
        }
      } catch (_) {}
      _controller.setLooping(true);
      await _controller.initialize().timeout(const Duration(seconds: 20));
      // ensure crossOrigin after initialization too
      try {
        final vids2 = html.document.getElementsByTagName('video');
        if (vids2.isNotEmpty) {
          final v2 = vids2.last as html.VideoElement;
          v2.crossOrigin = 'anonymous';
        }
      } catch (_) {}
      if (!mounted) return;
      setState(() { _initialized = true; });
      _controller.play();
    } catch (e) {
      debugPrint('Erreur initialisation video: $e');
      if (!mounted) return;
      setState(() { _error = true; });
    }
  }

  @override
  void dispose() {
    if (_initialized) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error) return _buildErrorWidget();
    if (!_initialized) return const Center(child: CircularProgressIndicator());

    final width = _controller.value.size.width > 0 ? _controller.value.size.width : double.infinity;
    final height = _controller.value.size.height > 0 ? _controller.value.size.height : 200;

    return GestureDetector(
      onTap: () { setState(() { _controller.value.isPlaying ? _controller.pause() : _controller.play(); }); },
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: width,
              height: height,
              child: VideoPlayer(_controller),
            ),
          ),
          if (!_controller.value.isPlaying)
            const Center(child: Icon(Icons.play_circle_outline, size: 64, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.play_circle_outline, size: 64, color: Colors.white54),
            const SizedBox(height: 8),
            const Text('Lecture non supportée', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                final uri = Uri.parse(widget.url);
                if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                  debugPrint('Impossible d\'ouvrir ${widget.url}');
                }
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Ouvrir la vidéo'),
            ),
          ],
        ),
      ),
    );
  }
}
