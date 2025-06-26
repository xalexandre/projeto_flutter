import 'package:flutter/material.dart';

/// Classe que define as cores padrão do aplicativo
/// 
/// Esta classe contém constantes para as cores usadas em todo o aplicativo,
/// garantindo consistência visual e facilitando mudanças de tema.
class AppColors {
  /// Construtor privado para evitar instanciação
  AppColors._();
  
  /// Cor primária do aplicativo
  static const Color primary = Color(0xFF2196F3);
  
  /// Variação mais clara da cor primária
  static const Color primaryLight = Color(0xFF64B5F6);
  
  /// Variação mais escura da cor primária
  static const Color primaryDark = Color(0xFF1976D2);
  
  /// Cor de acento/destaque
  static const Color accent = Color(0xFFFF9800);
  
  /// Cor para elementos de sucesso
  static const Color success = Color(0xFF4CAF50);
  
  /// Cor para elementos de erro
  static const Color error = Color(0xFFF44336);
  
  /// Cor para elementos de aviso
  static const Color warning = Color(0xFFFFEB3B);
  
  /// Cor para elementos de informação
  static const Color info = Color(0xFF2196F3);
  
  /// Cor para texto primário
  static const Color textPrimary = Color(0xFF212121);
  
  /// Cor para texto secundário
  static const Color textSecondary = Color(0xFF757575);
  
  /// Cor para texto desabilitado
  static const Color textDisabled = Color(0xFFBDBDBD);
  
  /// Cor para plano de fundo
  static const Color background = Color(0xFFFAFAFA);
  
  /// Cor para superfícies de cartões
  static const Color surface = Color(0xFFFFFFFF);
  
  /// Cor para divider
  static const Color divider = Color(0xFFE0E0E0);
  
  /// Cor para overlay
  static const Color overlay = Color(0x80000000);
  
  /// Cores de prioridade para tarefas
  static const Map<int, Color> priorityColors = {
    0: Color(0xFF9E9E9E), // Baixa
    1: Color(0xFF2196F3), // Normal
    2: Color(0xFFFFC107), // Alta
    3: Color(0xFFF44336), // Urgente
  };
  
  /// Retorna a cor correspondente à prioridade
  static Color getPriorityColor(int priority) {
    return priorityColors[priority] ?? priorityColors[1]!;
  }
}
