import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../domain/reason_media_item.dart';

class ReasonMediaViewer extends StatefulWidget {
  const ReasonMediaViewer({required this.item, super.key});
  final ReasonMediaItem item;
  @override
  State<ReasonMediaViewer> createState() => _ReasonMediaViewerState();
}

class _ReasonMediaViewerState extends State<ReasonMediaViewer> {
  VideoPlayerController? _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    if (widget.item.type == ReasonMediaType.video) _prepareVideo();
  }

  Future<void> _prepareVideo() async {
    final controller = VideoPlayerController.file(File(widget.item.path));
    await controller.initialize();
    if (!mounted) { await controller.dispose(); return; }
    setState(() { _controller = controller; _ready = true; });
  }

  @override
  void dispose() { _controller?.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isPhoto = widget.item.type == ReasonMediaType.photo;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('My Reason'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: isPhoto
                    ? InteractiveViewer(child: Image.file(File(widget.item.path)))
                    : !_ready
                        ? const CircularProgressIndicator()
                        : AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio,
                            child: VideoPlayer(_controller!),
                          ),
              ),
            ),
            if (!isPhoto && _ready)
              Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      _controller!.value.isPlaying
                          ? _controller!.pause()
                          : _controller!.play();
                    });
                  },
                  icon: Icon(_controller!.value.isPlaying ? Icons.pause : Icons.play_arrow),
                  label: Text(_controller!.value.isPlaying ? 'Pause' : 'Play'),
                ),
              ),
            if (widget.item.caption.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Text(widget.item.caption, style: const TextStyle(color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }
}
