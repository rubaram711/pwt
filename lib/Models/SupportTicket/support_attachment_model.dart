class SupportAttachmentModel {

  final int? id;
  final String? fileName;
  final String? fileUrl;

  SupportAttachmentModel({
    this.id,
    this.fileName,
    this.fileUrl,
  });

  factory SupportAttachmentModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return SupportAttachmentModel(

      id: json['id'],

      fileName: json['file_name'],

      fileUrl: json['file_url'],
    );
  }
}