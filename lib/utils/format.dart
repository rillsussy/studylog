const _bulan = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

String _dua(int n) => n.toString().padLeft(2, '0');

String formatTanggalSaja(DateTime t) =>
    '${t.day} ${_bulan[t.month - 1]} ${t.year}';

String formatTanggal(DateTime t) =>
    '${formatTanggalSaja(t)}, ${_dua(t.hour)}:${_dua(t.minute)}';
