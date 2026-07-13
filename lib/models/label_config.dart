class LabelItem {
  final String name;
  int lastNumber;

  LabelItem({required this.name, this.lastNumber = 0});

  factory LabelItem.fromJson(Map<String, dynamic> json) {
    return LabelItem(
      name: json['name'] as String,
      lastNumber: json['lastNumber'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'lastNumber': lastNumber,
  };
}

class PhotoInfo {
  final String fileName;
  final String label;
  final int number;
  final String filePath;
  final DateTime date;

  PhotoInfo({
    required this.fileName,
    required this.label,
    required this.number,
    required this.filePath,
    required this.date,
  });
}
