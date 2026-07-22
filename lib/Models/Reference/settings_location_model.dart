class SettingsLocationModel {
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? mapUrl;

  SettingsLocationModel({this.address, this.latitude, this.longitude, this.mapUrl});

  factory SettingsLocationModel.fromJson(Map<String, dynamic> json) => SettingsLocationModel(
        address: json['address'],
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        mapUrl: json['map_url'],
      );

  Map<String, dynamic> toJson() => {
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'map_url': mapUrl,
      };
}
