class Profile {
  int? id;
  String? name, bio, avatarUrl;

  Profile({this.id, this.name, this.bio, this.avatarUrl});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
        id: json['id'],
        name: json['name'],
        bio: json['bio'],
        avatarUrl: json['avaatar_url']);
  }
}
