String formatTanggal(DateTime t) {
  const bulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];
  String dua(int n) => n.toString().padLeft(2, '0');
  return '${t.day} ${bulan[t.month - 1]} ${t.year}, ${dua(t.hour)}:${dua(t.minute)}';
}
