class Contact {
  String? id, nama, nomor;

  Contact({this.id, this.nama, this.nomor});

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      nama: json['nama'],
      nomor: json['nomor'],
    );
  }
}
