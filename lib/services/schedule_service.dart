import '../data/bus_schedule_data.dart';
import '../models/bus_schedule.dart';

/// Centraliza toda a logica de calculo relacionada aos horarios de onibus:
/// dia da semana, proximos onibus e tempo restante.
///
/// Mantida separada da interface para facilitar testes e manutencao.
class ScheduleService {
  const ScheduleService._();

  static List<BusSchedule> get centroToSitio => centroToSitioFloresta;

  static List<BusSchedule> get sitioToCentro => sitioFlorestaToCentro;

  /// Retorna true se [date] cair em um dia util (segunda a sexta-feira).
  static bool isWeekday(DateTime date) {
    return date.weekday >= DateTime.monday && date.weekday <= DateTime.friday;
  }

  /// Retorna os proximos [count] onibus de [schedule] em relacao a [now].
  ///
  /// Um onibus cujo horario ja passou (em minutos) e excluido. Um onibus
  /// cujo horario seja exatamente igual ao minuto atual ainda e
  /// considerado "proximo".
  static List<BusSchedule> getNextBuses(
    List<BusSchedule> schedule,
    DateTime now, {
    int count = 2,
  }) {
    try {
      final nowMinutes = now.hour * 60 + now.minute;
      final upcoming = schedule
          .where((bus) => bus.totalMinutes >= nowMinutes)
          .toList()
        ..sort((a, b) => a.totalMinutes.compareTo(b.totalMinutes));
      if (upcoming.length <= count) return upcoming;
      return upcoming.sublist(0, count);
    } catch (_) {
      // Nunca deixar um erro inesperado quebrar a tela.
      return const [];
    }
  }

  /// Minutos restantes ate a partida de [bus], em relacao a [now].
  /// Nunca retorna valor negativo; retorna 0 quando o onibus esta
  /// partindo "agora".
  static int minutesUntil(BusSchedule bus, DateTime now) {
    final target = DateTime(now.year, now.month, now.day, bus.hour, bus.minute);
    final diffSeconds = target.difference(now).inSeconds;
    if (diffSeconds <= 0) return 0;
    return (diffSeconds / 60).ceil();
  }

  /// Primeiro horario do dataset de [schedule], usado apenas como
  /// referencia informativa para o "proximo dia util".
  static BusSchedule? firstOfDay(List<BusSchedule> schedule) {
    if (schedule.isEmpty) return null;
    final sorted = [...schedule]
      ..sort((a, b) => a.totalMinutes.compareTo(b.totalMinutes));
    return sorted.first;
  }
}
