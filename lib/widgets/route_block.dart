import 'package:flutter/material.dart';

import '../models/bus_schedule.dart';
import 'route_bus_card.dart';

/// Um dos quatro blocos numerados da rota diaria (ex: "1. SÍTIO FLORESTA
/// -> CENTRO"): titulo, subtitulo, ultimo horario e os dois proximos
/// onibus lado a lado. Reutiliza os mesmos dados de [nextBuses] e
/// [lastBus] ja calculados por ScheduleService — nenhuma logica de
/// horario vive aqui.
class RouteBlock extends StatelessWidget {
  final int number;
  final String title;
  final String subtitle;
  final Color color;
  final BusSchedule? lastBus;
  final List<BusSchedule> nextBuses;
  final DateTime now;

  const RouteBlock({
    super.key,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.lastBus,
    required this.nextBuses,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 38, bottom: 10),
            child: lastBus != null
                ? Text(
                    'Último horário: ${lastBus!.time}',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  )
                : const SizedBox.shrink(),
          ),
          if (nextBuses.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Não há mais ônibus hoje.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: RouteBusCard(
                    bus: nextBuses[0],
                    now: now,
                    color: color,
                    isPrimary: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: nextBuses.length > 1
                      ? RouteBusCard(
                          bus: nextBuses[1],
                          now: now,
                          color: color,
                          isPrimary: false,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
