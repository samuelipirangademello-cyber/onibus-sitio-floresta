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

  static List<BusSchedule> get centroToUfpel => centroToUfpelAnglo;

  static List<BusSchedule> get ufpelToCentro => ufpelAngloToCentro;

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

  /// Retorna o "ultimo horario" de [schedule] em relacao a [now]: o
  /// horario mais recente daquele sentido que ja ocorreu antes do minuto
  /// atual. Retorna null se nenhum horario do dia ainda ocorreu.
  ///
  /// Fica sempre imediatamente anterior ao primeiro item retornado por
  /// [getNextBuses], sem sobreposicao entre os dois (um horario cujo
  /// minuto seja exatamente igual ao atual continua sendo tratado como
  /// "proximo"/"agora", nao como "ultimo").
  static BusSchedule? getLastBus(List<BusSchedule> schedule, DateTime now) {
    try {
      final nowMinutes = now.hour * 60 + now.minute;
      final sorted = [...schedule]
        ..sort((a, b) => a.totalMinutes.compareTo(b.totalMinutes));
      BusSchedule? last;
      for (final bus in sorted) {
        if (bus.totalMinutes < nowMinutes) {
          last = bus;
        } else {
          break;
        }
      }
      return last;
    } catch (_) {
      return null;
    }
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
