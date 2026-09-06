class ArtisanProfile {
  const ArtisanProfile({required this.name, required this.location, required this.languageCode});

  final String name;
  final String location;
  final String languageCode;

  Map<String, String> toJson() => <String, String>{
        'name': name,
        'location': location,
        'languageCode': languageCode,
      };

  factory ArtisanProfile.fromJson(Map<String, dynamic> json) => ArtisanProfile(
        name: json['name'] as String,
        location: json['location'] as String,
        languageCode: json['languageCode'] as String,
      );
}
