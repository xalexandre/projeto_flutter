import 'package:flutter/material.dart';

class ResponsiveUtil {
  static const Size _defaultDesignSize = Size(375, 812); // Base design size (iPhone X)

  static double deviceWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double deviceHeight(BuildContext context) => MediaQuery.of(context).size.height;

  // Verifica se o dispositivo está em orientação paisagem
  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;
      
  // Verifica se o dispositivo é um tablet (maior que 600dp de largura)
  static bool isTablet(BuildContext context) => deviceWidth(context) >= 600;
  
  // Verifica se o dispositivo é uma tela grande (maior que 900dp de largura)
  static bool isLargeScreen(BuildContext context) => deviceWidth(context) >= 900;

  // Retorna um valor adaptado proporcionalmente à largura da tela
  static double adaptiveWidth(BuildContext context, double value) {
    final screenWidth = deviceWidth(context);
    return screenWidth / _defaultDesignSize.width * value;
  }

  // Retorna um valor adaptado proporcionalmente à altura da tela
  static double adaptiveHeight(BuildContext context, double value) {
    final screenHeight = deviceHeight(context);
    return screenHeight / _defaultDesignSize.height * value;
  }

  // Retorna um tamanho de fonte adaptativo
  static double adaptiveFontSize(BuildContext context, double fontSize) {
    final screenWidth = deviceWidth(context);
    final scaleFactor = screenWidth / _defaultDesignSize.width;
    // Evita fontes excessivamente grandes
    final cappedScaleFactor = scaleFactor > 1.3 ? 1.3 : scaleFactor;
    return fontSize * cappedScaleFactor;
  }

  // Define a quantidade de colunas para uma grade baseado no tamanho da tela
  static int gridColumnCount(BuildContext context) {
    final width = deviceWidth(context);
    if (width > 1200) return 4; // Telas muito grandes
    if (width > 900) return 3; // Telas grandes
    if (width > 600) return 2; // Tablets
    return 1; // Celulares
  }
  
  // Retorna um EdgeInsets responsivo para uso em padding, margin, etc.
  static EdgeInsets responsivePadding(BuildContext context, {
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    if (all != null) {
      final adaptedValue = adaptiveWidth(context, all);
      return EdgeInsets.all(adaptedValue);
    }

    return EdgeInsets.only(
      left: left != null ? adaptiveWidth(context, left) : 
            horizontal != null ? adaptiveWidth(context, horizontal) : 0,
      top: top != null ? adaptiveHeight(context, top) : 
           vertical != null ? adaptiveHeight(context, vertical) : 0,
      right: right != null ? adaptiveWidth(context, right) : 
             horizontal != null ? adaptiveWidth(context, horizontal) : 0,
      bottom: bottom != null ? adaptiveHeight(context, bottom) : 
              vertical != null ? adaptiveHeight(context, vertical) : 0,
    );
  }
}
