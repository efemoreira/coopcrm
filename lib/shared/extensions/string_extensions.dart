/// Extensões de [String] para formatação de CPF, telefone e capitalização.
extension StringX on String {
  String get capitalize =>
      isEmpty ? this : this[0].toUpperCase() + substring(1);

  String get formatCPF {
    final d = replaceAll(RegExp(r'\D'), '');
    if (d.length != 11) return this;
    return '\${d.substring(0, 3)}.\${d.substring(3, 6)}.\${d.substring(6, 9)}-\${d.substring(9)}';
  }

  String get formatPhone {
    final d = replaceAll(RegExp(r'\D'), '');
    if (d.length == 11) {
      return '(\${d.substring(0, 2)}) \${d.substring(2, 7)}-\${d.substring(7)}';
    }
    return this;
  }
}
