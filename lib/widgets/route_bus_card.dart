import 'package:flutter/material.dart';

import '../models/bus_schedule.dart';
import '../services/schedule_service.dart';

/// Cartao de um horario dentro de um bloco de rota. Quando [isPrimary] e
/// true (o proximo onibus), exibe um selo "PRÓXIMO ÔNIBUS" em destaque;
/// caso contrario (o segundo proximo), exibe apenas um rotulo discreto.
class RouteBusCard extends StatelessWidget {
  final BusSchedule bus;
  final DateTime now;
  final Color color;
  final bool isPrimary;

  const RouteBusCard({
    super.key,
    required this.bus,
    required this.now,
    required this.color,
    required this.isPrimary,
  });

  static String _formatWait(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    if (remainder == 0) return '$hours h';
    return '$hours h $remainder min';
  }

  @override
  Widget build(BuildContext context) {
    final minutes = ScheduleService.minutesUntil(bus, now);
    final isNow = minutes <= 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(isPrimary ? 0.16 : 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(isPrimary ? 0.55 : 0.22),
          width: isPrimary ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPrimary)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'PRÓXIMO ÔNIBUS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            )
          else
            Text(
              'Segundo próximo',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.directions_bus_filled_rounded,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  bus.time,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            bus.line,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10.5, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isNow ? 'agora' : 'em ${_formatWait(minutes)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
