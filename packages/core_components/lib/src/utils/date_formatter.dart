import 'package:intl/intl.dart';

/// Utilitário para formatação de datas
/// 
/// Esta classe fornece métodos para formatar datas em diferentes formatos
/// para uso consistente em todo o aplicativo.
class DateFormatter {
  /// Construtor privado para evitar instanciação
  DateFormatter._();
  
  /// Formata uma data no formato completo (dia, mês e ano)
  /// 
  /// Exemplo: 01/01/2025
  static String formatFullDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
  
  /// Formata uma data no formato completo com hora (dia, mês, ano, hora e minuto)
  /// 
  /// Exemplo: 01/01/2025 14:30
  static String formatFullDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
  
  /// Formata uma data no formato curto (dia e mês)
  /// 
  /// Exemplo: 01/01
  static String formatShortDate(DateTime date) {
    return DateFormat('dd/MM').format(date);
  }
  
  /// Formata uma data no formato de hora (hora e minuto)
  /// 
  /// Exemplo: 14:30
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
  
  /// Formata uma data no formato relativo (hoje, ontem, amanhã, ou data completa)
  /// 
  /// Exemplos:
  /// - Hoje às 14:30
  /// - Ontem às 14:30
  /// - Amanhã às 14:30
  /// - 01/01/2025 14:30
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return 'Hoje às ${formatTime(date)}';
    } else if (dateOnly == yesterday) {
      return 'Ontem às ${formatTime(date)}';
    } else if (dateOnly == tomorrow) {
      return 'Amanhã às ${formatTime(date)}';
    } else {
      return formatFullDateTime(date);
    }
  }
  
  /// Formata uma duração em formato legível
  /// 
  /// Exemplos:
  /// - 2h 30min
  /// - 45min
  /// - 10s
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else if (minutes > 0) {
      return '${minutes}min';
    } else {
      return '${seconds}s';
    }
  }
  
  /// Retorna uma string indicando quanto tempo se passou desde a data fornecida
  /// 
  /// Exemplos:
  /// - agora
  /// - há 5 minutos
  /// - há 2 horas
  /// - há 3 dias
  /// - há 2 semanas
  /// - há 3 meses
  /// - há 1 ano
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inSeconds < 60) {
      return 'agora';
    } else if (difference.inMinutes < 60) {
      return 'há ${difference.inMinutes} ${_pluralize(difference.inMinutes, 'minuto', 'minutos')}';
    } else if (difference.inHours < 24) {
      return 'há ${difference.inHours} ${_pluralize(difference.inHours, 'hora', 'horas')}';
    } else if (difference.inDays < 7) {
      return 'há ${difference.inDays} ${_pluralize(difference.inDays, 'dia', 'dias')}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'há $weeks ${_pluralize(weeks, 'semana', 'semanas')}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'há $months ${_pluralize(months, 'mês', 'meses')}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'há $years ${_pluralize(years, 'ano', 'anos')}';
    }
  }
  
  /// Retorna uma string indicando quanto tempo falta até a data fornecida
  /// 
  /// Exemplos:
  /// - em 5 minutos
  /// - em 2 horas
  /// - em 3 dias
  /// - em 2 semanas
  static String timeUntil(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    
    if (difference.inSeconds < 60) {
      return 'em instantes';
    } else if (difference.inMinutes < 60) {
      return 'em ${difference.inMinutes} ${_pluralize(difference.inMinutes, 'minuto', 'minutos')}';
    } else if (difference.inHours < 24) {
      return 'em ${difference.inHours} ${_pluralize(difference.inHours, 'hora', 'horas')}';
    } else if (difference.inDays < 7) {
      return 'em ${difference.inDays} ${_pluralize(difference.inDays, 'dia', 'dias')}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'em $weeks ${_pluralize(weeks, 'semana', 'semanas')}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'em $months ${_pluralize(months, 'mês', 'meses')}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'em $years ${_pluralize(years, 'ano', 'anos')}';
    }
  }
  
  /// Função auxiliar para pluralizar palavras
  static String _pluralize(int count, String singular, String plural) {
    return count == 1 ? singular : plural;
  }
}
