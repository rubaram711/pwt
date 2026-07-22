class FileModel {
  final int id;
  final String uuid;
  final String url;
  final String mime;
  final int size;
  final String type;
  final String createdAt;

  FileModel({
    required this.id,
    required this.uuid,
    required this.url,
    required this.mime,
    required this.size,
    required this.type,
    required this.createdAt,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['id'],
      uuid: json['uuid'],
      url: json['url'],
      mime: json['mime'],
      size: json['size'],
      type: json['type'],
      createdAt: json['created_at'],
    );
  }
}