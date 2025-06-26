import 'package:flutter/material.dart';

/// Utilitário para ajudar na criação de interfaces responsivas
/// 
/// Esta classe fornece métodos para determinar o tipo de dispositivo,
/// calcular tamanhos adaptativos e aplicar diferentes layouts com base no tamanho da tela.
class ResponsiveHelper {
  /// Construtor privado para evitar instanciação
  ResponsiveHelper._();
  
  /// Largura máxima para considerar um dispositivo como celular
  static const double mobileMaxWidth = 600;
  
  /// Largura máxima para considerar um dispositivo como tablet
  static const double tabletMaxWidth = 1024;
  
  /// Verifica se o dispositivo é um celular
  /// 
  /// Baseado na largura da tela
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileMaxWidth;
  }
  
  /// Verifica se o dispositivo é um tablet
  /// 
  /// Baseado na largura da tela
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileMaxWidth && width < tabletMaxWidth;
  }
  
  /// Verifica se o dispositivo é um desktop
  /// 
  /// Baseado na largura da tela
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletMaxWidth;
  }
  
  /// Verifica se o dispositivo está em orientação paisagem
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
  
  /// Verifica se o dispositivo está em orientação retrato
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }
  
  /// Calcula um valor adaptativo com base no tipo de dispositivo
  /// 
  /// Retorna diferentes valores para celular, tablet e desktop
  static T adaptiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
  
  /// Calcula uma largura adaptativa com base na largura da tela
  /// 
  /// Retorna um valor proporcional à largura da tela
  static double adaptiveWidth(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * (percentage / 100);
  }
  
  /// Calcula uma altura adaptativa com base na altura da tela
  /// 
  /// Retorna um valor proporcional à altura da tela
  static double adaptiveHeight(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * (percentage / 100);
  }
  
  /// Calcula um tamanho de fonte adaptativo com base no tipo de dispositivo
  /// 
  /// Retorna diferentes tamanhos para celular, tablet e desktop
  static double adaptiveFontSize(
    BuildContext context,
    double size, {
    double? tabletFactor,
    double? desktopFactor,
  }) {
    if (isDesktop(context)) {
      return size * (desktopFactor ?? 1.3);
    } else if (isTablet(context)) {
      return size * (tabletFactor ?? 1.15);
    } else {
      return size;
    }
  }
  
  /// Retorna um padding responsivo com base no tipo de dispositivo
  /// 
  /// Retorna diferentes valores de padding para celular, tablet e desktop
  static EdgeInsets responsivePadding(
    BuildContext context, {
    double horizontal = 16.0,
    double vertical = 16.0,
    double? tabletHorizontalFactor,
    double? tabletVerticalFactor,
    double? desktopHorizontalFactor,
    double? desktopVerticalFactor,
  }) {
    double horizontalPadding = horizontal;
    double verticalPadding = vertical;
    
    if (isDesktop(context)) {
      horizontalPadding *= (desktopHorizontalFactor ?? 2.0);
      verticalPadding *= (desktopVerticalFactor ?? 1.5);
    } else if (isTablet(context)) {
      horizontalPadding *= (tabletHorizontalFactor ?? 1.5);
      verticalPadding *= (tabletVerticalFactor ?? 1.2);
    }
    
    return EdgeInsets.symmetric(
      horizontal: horizontalPadding,
      vertical: verticalPadding,
    );
  }
  
  /// Retorna um widget diferente com base no tipo de dispositivo
  /// 
  /// Permite definir layouts completamente diferentes para celular, tablet e desktop
  static Widget responsiveBuilder({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    } else if (isTablet(context)) {
      return tablet ?? mobile;
    } else {
      return mobile;
    }
  }
  
  /// Retorna o número de colunas para um grid com base no tipo de dispositivo
  /// 
  /// Útil para definir o número de itens por linha em uma grade
  static int gridColumns(BuildContext context) {
    if (isDesktop(context)) {
      return 4;
    } else if (isTablet(context)) {
      return isLandscape(context) ? 3 : 2;
    } else {
      return isLandscape(context) ? 2 : 1;
    }
  }
  
  /// Calcula o tamanho ideal para um item de grid com base no tipo de dispositivo
  /// 
  /// Retorna a largura que um item deve ter para se adequar à grade
  static double gridItemWidth(BuildContext context, {double spacing = 16.0}) {
    final columns = gridColumns(context);
    final width = MediaQuery.of(context).size.width;
    final padding = spacing * (columns + 1);
    
    return (width - padding) / columns;
  }
}
