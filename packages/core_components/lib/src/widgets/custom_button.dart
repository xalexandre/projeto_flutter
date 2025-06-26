import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Um botão personalizado que mantém o estilo consistente em todo o aplicativo.
/// 
/// Este botão suporta diferentes variantes (primário, secundário, texto) e estados
/// (habilitado, desabilitado, carregando).
class CustomButton extends StatelessWidget {
  /// Texto a ser exibido no botão
  final String text;
  
  /// Função a ser chamada quando o botão for pressionado
  final VoidCallback? onPressed;
  
  /// Indica se o botão está em estado de carregamento
  final bool isLoading;
  
  /// Variante do botão (primário, secundário, texto)
  final CustomButtonVariant variant;
  
  /// Tamanho do botão (pequeno, médio, grande)
  final CustomButtonSize size;
  
  /// Ícone opcional para exibir antes do texto
  final IconData? icon;
  
  /// Cria um botão personalizado.
  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.variant = CustomButtonVariant.primary,
    this.size = CustomButtonSize.medium,
    this.icon,
  });
  
  /// Cria um botão primário.
  factory CustomButton.primary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    CustomButtonSize size = CustomButtonSize.medium,
    IconData? icon,
  }) {
    return CustomButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      variant: CustomButtonVariant.primary,
      size: size,
      icon: icon,
    );
  }
  
  /// Cria um botão secundário.
  factory CustomButton.secondary({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    CustomButtonSize size = CustomButtonSize.medium,
    IconData? icon,
  }) {
    return CustomButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      variant: CustomButtonVariant.secondary,
      size: size,
      icon: icon,
    );
  }
  
  /// Cria um botão de texto.
  factory CustomButton.text({
    Key? key,
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    CustomButtonSize size = CustomButtonSize.medium,
    IconData? icon,
  }) {
    return CustomButton(
      key: key,
      text: text,
      onPressed: onPressed,
      isLoading: isLoading,
      variant: CustomButtonVariant.text,
      size: size,
      icon: icon,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determinar padding com base no tamanho
    final EdgeInsets padding = _getPaddingForSize(size);
    
    // Determinar estilo com base na variante
    final ButtonStyle style = _getStyleForVariant(variant, theme);
    
    // Widget de carregamento
    final Widget loadingIndicator = SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(
          variant == CustomButtonVariant.primary ? Colors.white : theme.primaryColor,
        ),
      ),
    );
    
    // Construir botão baseado no tipo
    if (variant == CustomButtonVariant.text) {
      return TextButton(
        onPressed: isLoading ? null : onPressed,
        style: style,
        child: _buildButtonContent(isLoading, loadingIndicator),
      );
    } else {
      return ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: style,
        child: Padding(
          padding: padding,
          child: _buildButtonContent(isLoading, loadingIndicator),
        ),
      );
    }
  }
  
  /// Constrói o conteúdo interno do botão
  Widget _buildButtonContent(bool isLoading, Widget loadingIndicator) {
    if (isLoading) {
      return loadingIndicator;
    } else if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    } else {
      return Text(text);
    }
  }
  
  /// Retorna o padding apropriado para o tamanho do botão
  EdgeInsets _getPaddingForSize(CustomButtonSize size) {
    switch (size) {
      case CustomButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case CustomButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case CustomButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
    }
  }
  
  /// Retorna o estilo apropriado para a variante do botão
  ButtonStyle _getStyleForVariant(CustomButtonVariant variant, ThemeData theme) {
    switch (variant) {
      case CustomButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
      case CustomButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: AppColors.primary),
          ),
        );
      case CustomButtonVariant.text:
        return TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: EdgeInsets.zero,
        );
    }
  }
}

/// Enum para definir as variantes de botão disponíveis
enum CustomButtonVariant {
  /// Botão primário com cor de destaque
  primary,
  
  /// Botão secundário com borda e fundo transparente
  secondary,
  
  /// Botão de texto sem fundo ou borda
  text,
}

/// Enum para definir os tamanhos de botão disponíveis
enum CustomButtonSize {
  /// Botão pequeno para espaços restritos
  small,
  
  /// Botão médio para uso geral
  medium,
  
  /// Botão grande para destaque ou áreas de toque maiores
  large,
}
