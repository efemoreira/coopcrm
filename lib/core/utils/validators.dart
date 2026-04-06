/// Validadores de formulário reutilizáveis.
/// Compatíveis com `TextFormField.validator` — retornam `null` quando válido.
class Validators {
  Validators._();

  static String? required(String? value, {String label = 'Campo'}) {
    if (value == null || value.trim().isEmpty) return '\$label é obrigatório';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'E-mail é obrigatório';
    if (!RegExp(r'^[\w.-]+@[\w.-]+\.[a-z]{2,}\$').hasMatch(value)) return 'E-mail inválido';
    return null;
  }

  static String? cpf(String? value) {
    if (value == null || value.trim().isEmpty) return 'CPF é obrigatório';
    if (value.replaceAll(RegExp(r'\D'), '').length != 11) return 'CPF inválido';
    return null;
  }

  static String? minLength(String? value, int min) {
    if (value == null || value.length < min) return 'Mínimo de \$min caracteres';
    return null;
  }
}
