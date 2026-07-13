import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../models/label_config.dart';

class LabelConfigService {
  late File _configFile;
  List<LabelItem> _labels = [];

  List<LabelItem> get labels => _labels;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _configFile = File('${dir.path}/labels_config.json');

    if (!await _configFile.exists()) {
      await _copyDefaultConfig();
    }
    await _loadConfig();
  }

  Future<void> _copyDefaultConfig() async {
    final jsonStr = await rootBundle.loadString('assets/labels_config.json');
    await _configFile.writeAsString(jsonStr);
  }

  Future<void> _loadConfig() async {
    final jsonStr = await _configFile.readAsString();
    final List<dynamic> list = jsonDecode(jsonStr);
    _labels = list.map((e) => LabelItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _saveConfig() async {
    final json = jsonEncode(_labels.map((e) => e.toJson()).toList());
    await _configFile.writeAsString(json);
  }

  List<String> getLabelNames() => _labels.map((e) => e.name).toList();

  LabelItem? getLabelByName(String name) {
    try {
      return _labels.firstWhere((e) => e.name == name);
    } catch (_) {
      return null;
    }
  }

  bool addLabel(String name) {
    if (name.trim().isEmpty) return false;
    if (_labels.any((e) => e.name == name)) return false;
    _labels.add(LabelItem(name: name));
    _saveConfig();
    return true;
  }

  void deleteLabel(String name) {
    _labels.removeWhere((e) => e.name == name);
    _saveConfig();
  }

  int getNextNumber(String labelName) {
    final label = getLabelByName(labelName);
    if (label != null) {
      label.lastNumber += 1;
      _saveConfig();
      return label.lastNumber;
    }
    return -1;
  }

  int getCurrentNumber(String labelName) {
    return getLabelByName(labelName)?.lastNumber ?? 0;
  }

  String getPhotoFileName(String labelName, int number) {
    return '${labelName}_$number';
  }
}
