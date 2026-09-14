/// Representa um horario de onibus e a linha correspondente.
///
/// [time] deve estar sempre no formato "HH:mm" (24 horas).
class BusSchedule {
  final String time;
  final String line;

  const BusSchedule({
    required this.time,
    required this.line,
  });

  /// Hora extraida de [time]. Ex: "16:25" -> 16.
  int get hour => int.parse(time.split(':')[0]);

  /// Minuto extraido de [time]. Ex: "16:25" -> 25.
  int get minute => int.parse(time.split(':')[1]);

  /// Total de minutos desde a meia-noite, usado para comparacoes e
  /// ordenacao dos horarios ao longo do dia.
  int get totalMinutes => hour * 60 + minute;

  @override
  String toString() => '$time - $line';
}
