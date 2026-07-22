class ContactModel {

  final int? id;
  final String? name;
  final String? email;
  final String? subject;
  final String? source;
  final String? createdAt;

  ContactModel({
    this.id,
    this.name,
    this.email,
    this.subject,
    this.source,
    this.createdAt,
  });

  factory ContactModel.fromJson(
      Map<String, dynamic> json,
      ) {

    return ContactModel(

      id: json['id'],

      name: json['name'],

      email: json['email'],

      subject: json['subject'],

      source: json['source'],

      createdAt: json['created_at'],
    );
  }
}