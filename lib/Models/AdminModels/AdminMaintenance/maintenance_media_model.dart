class MaintenanceMediaModel {

  final int? id;

  final String? fileName;

  final String? url;

  MaintenanceMediaModel({
    this.id,
    this.fileName,
    this.url,
  });

  factory MaintenanceMediaModel.fromJson(
      Map<String, dynamic>? json,
      ) {

    if (json == null) {
      return MaintenanceMediaModel();
    }

    return MaintenanceMediaModel(

      id: json['id'],

      fileName: json['file_name'],

      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {

    return {

      'id': id,

      'file_name': fileName,

      'url': url,
    };
  }
}