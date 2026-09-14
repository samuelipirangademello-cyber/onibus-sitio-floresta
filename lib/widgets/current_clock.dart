import 'package:flutter/material.dart';

/// Exibe o relogio digital em tempo real ("HH:mm:ss") com o rotulo
/// "horario atual" abaixo.
class CurrentClock extends StatelessWidget {
  final DateTime now;

  const CurrentClock({super.key, required this.now});

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final formatted =
        '${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:${_twoDigits(now.second)}';

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.access_time_rounded, size: 28),
            const SizedBox(width: 8),
            Text(
              formatted,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'horário atual',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
