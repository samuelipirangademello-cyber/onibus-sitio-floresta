import 'package:flutter/material.dart';

import '../models/bus_schedule.dart';
import 'bus_time_card.dart';

/// Exibe um sentido (ex: "CENTRO -> SITIO FLORESTA") com o titulo e a
/// lista dos proximos onibus, ou uma mensagem caso nao haja mais onibus
/// naquele dia.
class DirectionCard extends StatelessWidget {
  final String title;
  final List<BusSchedule> nextBuses;
  final DateTime now;

  const DirectionCard({
    super.key,
    required this.title,
    required this.nextBuses,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          if (nextBuses.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Não há mais ônibus hoje.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            ...nextBuses.map((bus) => BusTimeCard(bus: bus, now: now)),
        ],
      ),
    );
  }
}
