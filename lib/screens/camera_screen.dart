import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../services/label_config_service.dart';
import '../services/photo_saver_service.dart';

class CameraScreen extends StatefulWidget {
  final String label;
  const CameraScreen({super.key, required this.label});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  final _configService = LabelConfigService();
  final _photoSaver = PhotoSaverService();
  int _photoCount = 0;
  int _nextNumber = 1;
  String _lastSavedName = '';
  bool _isInitialized = false;
  bool _isTakingPhoto = false;
  List<CameraDescription> _cameras = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    await _configService.init();
    _nextNumber = _configService.getCurrentNumber(widget.label) + 1;

    _cameras = await availableCameras();
    if (_cameras.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('没有检测到相机')),
        );
      }
      return;
    }

    _controller = CameraController(
      _cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras.first),
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller?.initialize();
    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  Future<void> _takePhoto() async {
    if (_isTakingPhoto || _controller == null || !_controller!.value.isInitialized) return;

    setState(() => _isTakingPhoto = true);

    try {
      final nextNum = _configService.getNextNumber(widget.label);
      final fileName = '${widget.label}_$nextNum';
      _nextNumber = nextNum + 1;

      final tempDir = Directory.systemTemp;
      final tempPath = '${tempDir.path}/capture_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _controller!.takePicture().then((XFile file) async {
        final bytes = await file.readAsBytes();
        await _photoSaver.savePhoto(bytes, widget.label, nextNum);

        _lastSavedName = fileName;
        _photoCount++;

        if (mounted) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已保存: $fileName'),
              duration: const Duration(seconds: 1),
              backgroundColor: Colors.green,
            ),
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('拍照失败: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isTakingPhoto = false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final previewSize = _controller!.value.previewSize!;
    final aspectRatio = previewSize.height / previewSize.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: 1 / aspectRatio,
              child: CameraPreview(_controller!),
            ),
          ),
          // Top bar
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, bottom: 8, left: 16, right: 16),
              color: Colors.black54,
              child: Row(
                children: [
                  Text('标签: ${widget.label}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text('已拍: $_photoCount 张',
                      style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ),
          // Next photo name hint
          Positioned(
            top: MediaQuery.of(context).padding.top + 50,
            left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _lastSavedName.isNotEmpty ? '已保存: $_lastSavedName' : '准备拍照',
                  style: const TextStyle(color: Colors.amber, fontSize: 14),
                ),
              ),
            ),
          ),
          // Bottom controls
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 16, top: 16, left: 16, right: 16),
              color: Colors.black54,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: const Text('返回', style: TextStyle(color: Colors.white)),
                  ),
                  GestureDetector(
                    onTap: _isTakingPhoto ? null : _takePhoto,
                    child: Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        color: _isTakingPhoto ? Colors.grey : Colors.orange.shade600,
                      ),
                      child: _isTakingPhoto
                          ? const Center(child: SizedBox(
                              width: 24, height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))
                          : const Icon(Icons.camera_alt, color: Colors.white, size: 36),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.swap_horiz, color: Colors.white),
                    label: const Text('切换标签', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
