import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoPlayerItem extends StatefulWidget {
  final String url;
  const VideoPlayerItem({super.key, required this.url});

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  VideoPlayerController? _vpController;
  VlcPlayerController? _vlcController;
  bool _initialized = false;
  bool _error = false;
  bool _usingVlc = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      // VideoPlayer standard
      _vpController = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      _vpController!.setLooping(true);
      await _vpController!.initialize().timeout(const Duration(seconds: 20));
      if (!mounted) return;
      setState(() {
        _initialized = true;
        _usingVlc = false;
      });
      _vpController!.play();
      return;
    } catch (e) {
      debugPrint('Erreur initialisation video: $e');
    }

    try {
      // VLC fallback
      _vlcController = VlcPlayerController.network(widget.url, autoInitialize: true, autoPlay: true);
      await _vlcController!.initialize();
      if (!mounted) return;
      setState(() {
        _initialized = true;
        _usingVlc = true;
      });
      return;
    } catch (e) {
      debugPrint('VLC failed: $e');
    }

    if (!mounted) return;
    setState(() {
      _error = true;
    });
  }

  @override
  void dispose() {
    _vpController?.dispose();
    _vlcController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error) return _buildErrorWidget();

    if (!_initialized) return const Center(child: CircularProgressIndicator());

    if (_usingVlc && _vlcController != null) {
      final size = _vlcController!.value.size;
      final aspect = (size.width > 0 && size.height > 0) ? (size.width / size.height) : (16 / 9);
      return VlcPlayer(controller: _vlcController!, aspectRatio: aspect);
    }

    if (_vpController != null) {
      final width = _vpController!.value.size.width > 0 ? _vpController!.value.size.width : double.infinity;
      final height = _vpController!.value.size.height > 0 ? _vpController!.value.size.height : 200;

      return GestureDetector(
        onTap: () {
          setState(() {
            _vpController!.value.isPlaying ? _vpController!.pause() : _vpController!.play();
          });
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: width,
                height: height,
                child: VideoPlayer(_vpController!),
              ),
            ),
            if (!_vpController!.value.isPlaying)
              const Center(child: Icon(Icons.play_circle_outline, size: 64, color: Colors.white70)),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
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
