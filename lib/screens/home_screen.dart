import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/label_config_service.dart';
import 'camera_screen.dart';
import 'config_edit_screen.dart';
import 'photo_view_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _configService = LabelConfigService();
  String? _selectedLabel;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initConfig();
  }

  Future<void> _initConfig() async {
    await _configService.init();
    setState(() {
      _initialized = true;
      if (_configService.labels.isNotEmpty) {
        _selectedLabel = _configService.labels.first.name;
      }
    });
  }

  Future<void> _refresh() async {
    await _configService.init();
    if (_configService.labels.isNotEmpty && _selectedLabel == null) {
      _selectedLabel = _configService.labels.first.name;
    }
    setState(() {});
  }

  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final labels = _configService.getLabelNames();
    final currentNum = _selectedLabel != null
        ? _configService.getCurrentNumber(_selectedLabel!)
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('\u6444\u5f71\u6807\u7b7e\u7ba1\u7406'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('\u8bf7\u9009\u62e9\u6807\u7b7e',
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedLabel,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: labels.map((label) {
                        return DropdownMenuItem(value: label, child: Text(label));
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedLabel = value),
                    ),
                  ],
                ),
              ),
            ),
            if (_selectedLabel != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text('\u6807\u7b7e: $_selectedLabel',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Spacer(),
                    Text(currentNum > 0 ? '\u5df2\u62cd $currentNum \u5f20' : '\u672a\u4f7f\u7528',
                        style: TextStyle(color: Colors.grey.shade700)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _selectedLabel == null ? null : () async {
                if (await _requestCameraPermission()) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CameraScreen(label: _selectedLabel!),
                    ),
                  ).then((_) => _refresh());
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('\u9700\u8981\u76f8\u673a\u6743\u9650')),
                  );
                }
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('\u5f00\u59cb\u62cd\u6444'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ConfigEditScreen()))
                  .then((_) => _refresh()),
              icon: const Icon(Icons.edit),
              label: const Text('\u7f16\u8f91\u6807\u7b7e'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PhotoViewScreen())),
              icon: const Icon(Icons.photo_library),
              label: const Text('\u67e5\u770b\u7167\u7247'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}