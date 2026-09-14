import 'package:flutter/material.dart';

import '../models/bus_schedule.dart';
import '../services/schedule_service.dart';

/// Exibe um unico horario de onibus: hora de partida, tempo restante
/// ("em X min" ou "agora") e a linha correspondente.
class BusTimeCard extends StatelessWidget {
  final BusSchedule bus;
  final DateTime now;

  const BusTimeCard({
    super.key,
    required this.bus,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = ScheduleService.minutesUntil(bus, now);
    final isNow = minutes <= 0;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isNow
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: isNow ? 1.6 : 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_bus_filled_rounded, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bus.time,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  bus.line,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isNow
                  ? theme.colorScheme.primary
                  : theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isNow ? 'agora' : 'em $minutes min',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isNow
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
