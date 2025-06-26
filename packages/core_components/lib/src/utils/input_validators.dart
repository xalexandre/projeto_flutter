/// Utilitário para validação de entradas
/// 
/// Esta classe fornece métodos estáticos para validar diferentes tipos de entradas
/// como email, senha, números, etc.
class InputValidators {
  /// Construtor privado para evitar instanciação
  InputValidators._();
  
  /// Valida um email
  /// 
  /// Retorna null se o email for válido, ou uma mensagem de erro caso contrário
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe um email';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor, informe um email válido';
    }
    
    return null;
  }
  
  /// Valida uma senha
  /// 
  /// Retorna null se a senha for válida, ou uma mensagem de erro caso contrário
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe uma senha';
    }
    
    if (value.length < 6) {
      return 'A senha deve ter no mínimo 6 caracteres';
    }
    
    return null;
  }
  
  /// Valida uma senha forte
  /// 
  /// Retorna null se a senha for forte, ou uma mensagem de erro caso contrário
  /// Uma senha forte deve ter pelo menos 8 caracteres, incluindo letras maiúsculas,
  /// minúsculas, números e caracteres especiais.
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe uma senha';
    }
    
    if (value.length < 8) {
      return 'A senha deve ter no mínimo 8 caracteres';
    }
    
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'A senha deve conter pelo menos uma letra maiúscula';
    }
    
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'A senha deve conter pelo menos uma letra minúscula';
    }
    
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'A senha deve conter pelo menos um número';
    }
    
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'A senha deve conter pelo menos um caractere especial';
    }
    
    return null;
  }
  
  /// Valida se dois campos são iguais (útil para confirmação de senha)
  /// 
  /// Retorna null se os campos forem iguais, ou uma mensagem de erro caso contrário
  static String? validateEquals(String? value1, String? value2, {String fieldName = 'campos'}) {
    if (value1 != value2) {
      return 'Os $fieldName não coincidem';
    }
    
    return null;
  }
  
  /// Valida se um campo não está vazio
  /// 
  /// Retorna null se o campo não estiver vazio, ou uma mensagem de erro caso contrário
  static String? validateRequired(String? value, {String fieldName = 'campo'}) {
    if (value == null || value.isEmpty) {
      return 'O $fieldName é obrigatório';
    }
    
    return null;
  }
  
  /// Valida um número
  /// 
  /// Retorna null se o valor for um número válido, ou uma mensagem de erro caso contrário
  static String? validateNumber(String? value, {String fieldName = 'valor'}) {
    if (value == null || value.isEmpty) {
      return 'O $fieldName é obrigatório';
    }
    
    if (double.tryParse(value) == null) {
      return 'O $fieldName deve ser um número válido';
    }
    
    return null;
  }
  
  /// Valida um número inteiro
  /// 
  /// Retorna null se o valor for um número inteiro válido, ou uma mensagem de erro caso contrário
  static String? validateInteger(String? value, {String fieldName = 'valor'}) {
    if (value == null || value.isEmpty) {
      return 'O $fieldName é obrigatório';
    }
    
    if (int.tryParse(value) == null) {
      return 'O $fieldName deve ser um número inteiro válido';
    }
    
    return null;
  }
  
  /// Valida se um número está dentro de um intervalo
  /// 
  /// Retorna null se o valor estiver dentro do intervalo, ou uma mensagem de erro caso contrário
  static String? validateRange(String? value, {
    required double min,
    required double max,
    String fieldName = 'valor',
  }) {
    final numberError = validateNumber(value, fieldName: fieldName);
    if (numberError != null) {
      return numberError;
    }
    
    final number = double.parse(value!);
    if (number < min) {
      return 'O $fieldName deve ser maior ou igual a $min';
    }
    
    if (number > max) {
      return 'O $fieldName deve ser menor ou igual a $max';
    }
    
    return null;
  }
  
  /// Valida um telefone brasileiro
  /// 
  /// Retorna null se o telefone for válido, ou uma mensagem de erro caso contrário
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe um telefone';
    }
    
    // Remove caracteres não numéricos
    final cleanedValue = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Verifica se tem entre 10 e 11 dígitos (com ou sem DDD)
    if (cleanedValue.length < 10 || cleanedValue.length > 11) {
      return 'Por favor, informe um telefone válido';
    }
    
    return null;
  }
  
  /// Valida um CPF
  /// 
  /// Retorna null se o CPF for válido, ou uma mensagem de erro caso contrário
  static String? validateCPF(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe um CPF';
    }
    
    // Remove caracteres não numéricos
    final cleanedValue = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Verifica se tem 11 dígitos
    if (cleanedValue.length != 11) {
      return 'O CPF deve conter 11 dígitos';
    }
    
    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cleanedValue)) {
      return 'O CPF informado é inválido';
    }
    
    // Validação do dígito verificador
    // Implementação simplificada - em um caso real seria mais completa
    return null;
  }
  
  /// Valida uma data
  /// 
  /// Retorna null se a data for válida, ou uma mensagem de erro caso contrário
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe uma data';
    }
    
    // Verifica se está no formato DD/MM/AAAA
    final dateRegex = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$');
    if (!dateRegex.hasMatch(value)) {
      return 'Por favor, informe uma data no formato DD/MM/AAAA';
    }
    
    // Extrai os componentes da data
    final match = dateRegex.firstMatch(value)!;
    final day = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final year = int.parse(match.group(3)!);
    
    // Verifica se a data é válida
    if (month < 1 || month > 12) {
      return 'Mês inválido';
    }
    
    // Verifica o número de dias no mês
    final daysInMonth = [31, _isLeapYear(year) ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (day < 1 || day > daysInMonth[month - 1]) {
      return 'Dia inválido para o mês informado';
    }
    
    return null;
  }
  
  /// Verifica se um ano é bissexto
  static bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }
  
  /// Valida um comprimento mínimo
  /// 
  /// Retorna null se o valor tiver pelo menos o número mínimo de caracteres,
  /// ou uma mensagem de erro caso contrário
  static String? validateMinLength(String? value, int minLength, {String fieldName = 'campo'}) {
    final requiredError = validateRequired(value, fieldName: fieldName);
    if (requiredError != null) {
      return requiredError;
    }
    
    if (value!.length < minLength) {
      return 'O $fieldName deve ter pelo menos $minLength caracteres';
    }
    
    return null;
  }
  
  /// Valida um comprimento máximo
  /// 
  /// Retorna null se o valor tiver no máximo o número máximo de caracteres,
  /// ou uma mensagem de erro caso contrário
  static String? validateMaxLength(String? value, int maxLength, {String fieldName = 'campo'}) {
    if (value == null || value.isEmpty) {
      return null; // Campo vazio é válido para comprimento máximo
    }
    
    if (value.length > maxLength) {
      return 'O $fieldName deve ter no máximo $maxLength caracteres';
    }
    
    return null;
  }
  
  /// Valida um comprimento exato
  /// 
  /// Retorna null se o valor tiver exatamente o número de caracteres especificado,
  /// ou uma mensagem de erro caso contrário
  static String? validateExactLength(String? value, int length, {String fieldName = 'campo'}) {
    final requiredError = validateRequired(value, fieldName: fieldName);
    if (requiredError != null) {
      return requiredError;
    }
    
    if (value!.length != length) {
      return 'O $fieldName deve ter exatamente $length caracteres';
    }
    
    return null;
  }
  
  /// Valida uma URL
  /// 
  /// Retorna null se a URL for válida, ou uma mensagem de erro caso contrário
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, informe uma URL';
    }
    
    final urlRegex = RegExp(
      r'^(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'Por favor, informe uma URL válida';
    }
    
    return null;
  }
  
  /// Combina múltiplos validadores
  /// 
  /// Retorna o primeiro erro encontrado ou null se todos os validadores passarem
  static String? validateMultiple(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) {
        return error;
      }
    }
    
    return null;
  }
}
