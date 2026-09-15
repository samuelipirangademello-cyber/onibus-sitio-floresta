import 'package:flutter_test/flutter_test.dart';
import 'package:onibus_sitio_floresta/models/bus_schedule.dart';
import 'package:onibus_sitio_floresta/services/schedule_service.dart';

void main() {
  group('ScheduleService.isWeekday', () {
    test('segunda-feira e considerada dia util', () {
      final monday = DateTime(2026, 9, 14); // segunda-feira
      expect(ScheduleService.isWeekday(monday), isTrue);
    });

    test('sabado nao e considerado dia util', () {
      final saturday = DateTime(2026, 9, 19);
      expect(ScheduleService.isWeekday(saturday), isFalse);
    });

    test('domingo nao e considerado dia util', () {
      final sunday = DateTime(2026, 9, 20);
      expect(ScheduleService.isWeekday(sunday), isFalse);
    });
  });

  group('ScheduleService.getNextBuses', () {
    test('segunda-feira pela manha retorna os dois primeiros onibus do dia', () {
      final now = DateTime(2026, 9, 14, 5, 0); // antes do primeiro horario
      final next = ScheduleService.getNextBuses(
        ScheduleService.centroToSitio,
        now,
      );
      expect(next.length, 2);
      expect(next[0].time, '05:50');
      expect(next[1].time, '07:10');
    });

    test('meio do dia retorna os proximos onibus corretos', () {
      final now = DateTime(2026, 9, 14, 12, 0);
      final next = ScheduleService.getNextBuses(
        ScheduleService.centroToSitio,
        now,
      );
      expect(next.length, 2);
      expect(next[0].time, '12:15');
      expect(next[1].time, '12:50');
    });

    test('horario entre dois onibus retorna o par correto (exemplo do spec)', () {
      final now = DateTime(2026, 9, 14, 15, 56);
      final next = ScheduleService.getNextBuses(
        ScheduleService.centroToSitio,
        now,
      );
      expect(next.length, 2);
      expect(next[0].time, '16:00');
      expect(next[1].time, '16:25');
    });

    test('horario exatamente igual a um onibus ainda o considera proximo', () {
      final now = DateTime(2026, 9, 14, 16, 0);
      final next = ScheduleService.getNextBuses(
        ScheduleService.centroToSitio,
        now,
      );
      expect(next.first.time, '16:00');
    });

    test('apos o ultimo horario do dia nao ha mais onibus', () {
      final now = DateTime(2026, 9, 14, 23, 59);
      final next = ScheduleService.getNextBuses(
        ScheduleService.centroToSitio,
        now,
      );
      expect(next, isEmpty);
    });
  });

  group('ScheduleService.getLastBus', () {
    test('cenario 1: as 12:52, ultimo e o horario mais recente ja ocorrido', () {
      final now = DateTime(2026, 9, 14, 12, 52);
      expect(
        ScheduleService.getLastBus(ScheduleService.centroToSitio, now)?.time,
        '12:50',
      );
      expect(
        ScheduleService.getLastBus(ScheduleService.sitioToCentro, now)?.time,
        '12:50',
      );
    });

    test('cenario 2: as 13:41, ultimo passa a ser 13:40', () {
      final now = DateTime(2026, 9, 14, 13, 41);
      expect(
        ScheduleService.getLastBus(ScheduleService.centroToSitio, now)?.time,
        '13:40',
      );
    });

    test('cenario 3: antes do primeiro horario do dia, nao ha ultimo horario', () {
      final now = DateTime(2026, 9, 14, 5, 0);
      expect(
        ScheduleService.getLastBus(ScheduleService.centroToSitio, now),
        isNull,
      );
    });

    test('cenario 4: apos o ultimo horario do dia, o ultimo e o derradeiro da lista', () {
      final now = DateTime(2026, 9, 14, 23, 59);
      expect(
        ScheduleService.getLastBus(ScheduleService.centroToSitio, now)?.time,
        '23:20',
      );
    });

    test('um horario exatamente igual ao minuto atual nao e considerado ultimo', () {
      final now = DateTime(2026, 9, 14, 16, 0);
      expect(
        ScheduleService.getLastBus(ScheduleService.centroToSitio, now)?.time,
        '15:25',
      );
    });
  });

  group('ScheduleService.minutesUntil', () {
    test('calcula minutos restantes corretamente (exemplo do spec)', () {
      final now = DateTime(2026, 9, 14, 15, 56);
      const bus = BusSchedule(time: '16:00', line: 'teste');
      expect(ScheduleService.minutesUntil(bus, now), 4);
    });

    test('retorna 0 (agora) quando o horario coincide exatamente', () {
      final now = DateTime(2026, 9, 14, 16, 0);
      const bus = BusSchedule(time: '16:00', line: 'teste');
      expect(ScheduleService.minutesUntil(bus, now), 0);
    });

    test('nunca retorna valor negativo', () {
      final now = DateTime(2026, 9, 14, 16, 5);
      const bus = BusSchedule(time: '16:00', line: 'teste');
      expect(ScheduleService.minutesUntil(bus, now), 0);
    });
  });

  group('ScheduleService — novos sentidos (Centro <-> UFPel / Anglo)', () {
    test('centroToUfpel: proximos as 17:16 (exemplo do mockup)', () {
      final now = DateTime(2026, 9, 15, 17, 16);
      final next = ScheduleService.getNextBuses(
        ScheduleService.centroToUfpel,
        now,
      );
      expect(next.length, 2);
      expect(next[0].time, '17:40');
      expect(next[1].time, '17:57');
    });

    test('ufpelToCentro: proximos as 17:16 (exemplo do mockup)', () {
      final now = DateTime(2026, 9, 15, 17, 16);
      final next = ScheduleService.getNextBuses(
        ScheduleService.ufpelToCentro,
        now,
      );
      expect(next.length, 2);
      expect(next[0].time, '17:25');
      expect(next[1].time, '17:37');
    });

    test('ultimo horario dos quatro sentidos as 17:16 (exemplo do mockup)', () {
      final now = DateTime(2026, 9, 15, 17, 16);
      expect(
        ScheduleService.getLastBus(ScheduleService.sitioToCentro, now)?.time,
        '17:05',
      );
      expect(
        ScheduleService.getLastBus(ScheduleService.centroToUfpel, now)?.time,
        '17:15',
      );
      expect(
        ScheduleService.getLastBus(ScheduleService.ufpelToCentro, now)?.time,
        '16:57',
      );
      expect(
        ScheduleService.getLastBus(ScheduleService.centroToSitio, now)?.time,
        '16:57',
      );
    });
  });
}
