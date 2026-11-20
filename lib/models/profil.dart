class Profil {
  final String nama;
  final String nim;
  final String kelas;
  final String prodi;
  final String semester;
  final String institusi;

  const Profil({
    required this.nama,
    required this.nim,
    required this.kelas,
    required this.prodi,
    required this.semester,
    required this.institusi,
  });

  factory Profil.defaultProfil() => const Profil(
    nama: 'Ryanda Hermawan',
    nim: '2411068',
    kelas: 'IFB5J',
    prodi: 'S1 Informatika',
    semester: 'Semester 5',
    institusi: 'Universitas Mulia Balikpapan',
  );

  Profil copyWith({
    String? nama,
    String? nim,
    String? kelas,
    String? prodi,
    String? semester,
    String? institusi,
  }) => Profil(
    nama: nama ?? this.nama,
    nim: nim ?? this.nim,
    kelas: kelas ?? this.kelas,
    prodi: prodi ?? this.prodi,
    semester: semester ?? this.semester,
    institusi: institusi ?? this.institusi,
  );

  Map<String, Object?> toMap() => {
    'nama': nama,
    'nim': nim,
    'kelas': kelas,
    'prodi': prodi,
    'semester': semester,
    'institusi': institusi,
  };

  factory Profil.fromMap(Map<String, Object?> m) => Profil(
    nama: (m['nama'] as String?)?.trim().isNotEmpty == true
        ? m['nama'] as String
        : 'Ryanda Hermawan',
    nim: (m['nim'] as String?)?.trim().isNotEmpty == true
        ? m['nim'] as String
        : '2411068',
    kelas: (m['kelas'] as String?)?.trim().isNotEmpty == true
        ? m['kelas'] as String
        : 'IFB5J',
    prodi: (m['prodi'] as String?)?.trim().isNotEmpty == true
        ? m['prodi'] as String
        : 'S1 Informatika',
    semester: (m['semester'] as String?)?.trim().isNotEmpty == true
        ? m['semester'] as String
        : 'Semester 5',
    institusi: (m['institusi'] as String?)?.trim().isNotEmpty == true
        ? m['institusi'] as String
        : 'Universitas Mulia Balikpapan',
  );
}
