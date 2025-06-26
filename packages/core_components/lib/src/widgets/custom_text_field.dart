import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// Um campo de texto personalizado que mantém o estilo consistente em todo o aplicativo.
/// 
/// Este campo de texto suporta diferentes variantes, validação, e formatação.
class CustomTextField extends StatelessWidget {
  /// O controlador do campo de texto
  final TextEditingController? controller;
  
  /// O rótulo a ser exibido
  final String label;
  
  /// A dica a ser exibida quando o campo estiver vazio
  final String? hint;
  
  /// O ícone a ser exibido no início do campo
  final IconData? prefixIcon;
  
  /// O ícone a ser exibido no final do campo
  final IconData? suffixIcon;
  
  /// A função a ser chamada quando o ícone de sufixo for pressionado
  final VoidCallback? onSuffixIconPressed;
  
  /// A função a ser chamada quando o valor do campo mudar
  final ValueChanged<String>? onChanged;
  
  /// A função a ser chamada quando o campo perder o foco
  final ValueChanged<String>? onSubmitted;
  
  /// A função de validação do campo
  final String? Function(String?)? validator;
  
  /// Os formatadores de entrada
  final List<TextInputFormatter>? inputFormatters;
  
  /// O tipo de teclado
  final TextInputType? keyboardType;
  
  /// Se o campo deve ser obscurecido (para senhas)
  final bool obscureText;
  
  /// Se o campo está habilitado
  final bool enabled;
  
  /// O número máximo de linhas
  final int? maxLines;
  
  /// O número mínimo de linhas
  final int? minLines;
  
  /// O texto de erro a ser exibido
  final String? errorText;
  
  /// Se o campo é obrigatório
  final bool required;

  /// Cria um campo de texto personalizado.
  const CustomTextField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.inputFormatters,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.errorText,
    this.required = false,
  });
  
  /// Cria um campo de texto para email.
  factory CustomTextField.email({
    Key? key,
    TextEditingController? controller,
    String label = 'Email',
    String? hint = 'Digite seu email',
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    String? Function(String?)? validator,
    bool enabled = true,
    bool required = true,
    String? errorText,
  }) {
    return CustomTextField(
      key: key,
      controller: controller,
      label: label,
      hint: hint,
      prefixIcon: Icons.email_outlined,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      validator: validator ?? _defaultEmailValidator,
      keyboardType: TextInputType.emailAddress,
      enabled: enabled,
      required: required,
      errorText: errorText,
    );
  }
  
  /// Cria um campo de texto para senha.
  factory CustomTextField.password({
    Key? key,
    TextEditingController? controller,
    String label = 'Senha',
    String? hint = 'Digite sua senha',
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    String? Function(String?)? validator,
    bool enabled = true,
    bool required = true,
    String? errorText,
  }) {
    return CustomTextField(
      key: key,
      controller: controller,
      label: label,
      hint: hint,
      prefixIcon: Icons.lock_outline,
      suffixIcon: Icons.visibility_outlined,
      onSuffixIconPressed: () {
        // Esta função seria implementada no StatefulWidget que contém este campo
      },
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      validator: validator ?? _defaultPasswordValidator,
      obscureText: true,
      enabled: enabled,
      required: required,
      errorText: errorText,
    );
  }
  
  /// Cria um campo de texto para pesquisa.
  factory CustomTextField.search({
    Key? key,
    TextEditingController? controller,
    String label = 'Pesquisar',
    String? hint = 'Digite para pesquisar',
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    bool enabled = true,
    String? errorText,
  }) {
    return CustomTextField(
      key: key,
      controller: controller,
      label: label,
      hint: hint,
      prefixIcon: Icons.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      errorText: errorText,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        errorText: errorText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon),
                onPressed: onSuffixIconPressed,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        filled: true,
        fillColor: enabled ? Colors.transparent : Colors.grey[100],
      ),
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      style: TextStyle(
        color: enabled ? AppColors.textPrimary : AppColors.textDisabled,
      ),
    );
  }
}

/// Validador padrão para campos de email
String? _defaultEmailValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Por favor, informe um email';
  }
  
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Por favor, informe um email válido';
  }
  
  return null;
}

/// Validador padrão para campos de senha
String? _defaultPasswordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Por favor, informe uma senha';
  }
  
  if (value.length < 6) {
    return 'A senha deve ter no mínimo 6 caracteres';
  }
  
  return null;
}
