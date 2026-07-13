import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/label_config.dart';

class PhotoSaverService {
  static const photoDirName = 'PhotoLabelApp';
  static const photoExt = '.jpg';

  Future<Directory> get _rootDir async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/$photoDirName');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<Directory> getLabelDir(String label) async {
    final root = await _rootDir;
    final dir = Directory('${root.path}/$label');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<String?> savePhoto(List<int> bytes, String label, int number) async {
    try {
      final fileName = '${label}_$number$photoExt';
      final labelDir = await getLabelDir(label);
      final file = File('${labelDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      return null;
    }
  }

  Future<List<PhotoInfo>> getPhotosByLabel(String label) async {
    final labelDir = await getLabelDir(label);
    if (!await labelDir.exists()) return [];

    final photos = <PhotoInfo>[];
    final files = await labelDir.list().toList();

    for (final file in files.whereType<File>()) {
      if (!file.path.endsWith(photoExt)) continue;

      final nameWithoutExt = file.path
          .split('/')
          .last
          .replaceAll(photoExt, '');
      final parts = nameWithoutExt.split('_');

      String photoLabel = label;
      int number = 0;

      if (parts.length >= 2) {
        photoLabel = parts[0];
        number = int.tryParse(parts[1]) ?? 0;
      }

      final stat = await file.stat();
      photos.add(PhotoInfo(
        fileName: nameWithoutExt,
        label: photoLabel,
        number: number,
        filePath: file.path,
        date: stat.modified,
      ));
    }

    photos.sort((a, b) => a.filePath.compareTo(b.filePath));
    return photos;
  }

  Future<int> getActualPhotoCount(String label) async {
    final photos = await getPhotosByLabel(label);
    return photos.length;
  }

  Future<int> getMaxNumberForLabel(String label) async {
    final photos = await getPhotosByLabel(label);
    if (photos.isEmpty) return 0;
    return photos.map((p) => p.number).reduce((a, b) => a > b ? a : b);
  }

  Future<List<Map<String, dynamic>>> getLabelStats() async {
    final root = await _rootDir;
    if (!await root.exists()) return [];

    final stats = <Map<String, dynamic>>[];
    final dirs = await root.list().toList();

    for (final dir in dirs.whereType<Directory>()) {
      final label = dir.path.split('/').last;
      final count = await getActualPhotoCount(label);
      stats.add({'label': label, 'count': count});
    }

    stats.sort((a, b) => (a['label'] as String).compareTo(b['label'] as String));
    return stats;
  }
}
