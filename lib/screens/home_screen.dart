import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/schedule_service.dart';
import '../widgets/current_clock.dart';
import '../widgets/direction_card.dart';

const String _horariosSiteUrl = 'https://www.portalprati.com.br/pelotas/horarios';

/// Tela unica do aplicativo: relogio, e os proximos onibus nos dois
/// sentidos (ou o aviso de fim de semana). Atualiza automaticamente a
/// cada segundo atraves de um unico Timer centralizado.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _now;
  Timer? _timer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  void _refresh() {
    setState(() {
      _now = DateTime.now();
      _errorMessage = null;
    });
  }

  Future<void> _openHorariosSite() async {
    try {
      final uri = Uri.parse(_horariosSiteUrl);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        _showSnackBar('Não foi possível abrir o link.');
      }
    } catch (_) {
      if (mounted) {
        _showSnackBar('Não foi possível abrir o link.');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'HORÁRIOS DE ÔNIBUS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Sítio Floresta',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 18),
              CurrentClock(now: _now),
              const SizedBox(height: 26),
              const Divider(height: 1),
              const SizedBox(height: 22),
              if (_errorMessage != null)
                _ErrorCard(message: _errorMessage!)
              else if (!ScheduleService.isWeekday(_now))
                _WeekendNotice(onOpenSite: _openHorariosSite)
              else
                _buildSchedules(),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Atualizar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSchedules() {
    try {
      final nextCentroToSitio = ScheduleService.getNextBuses(
        ScheduleService.centroToSitio,
        _now,
      );
      final nextSitioToCentro = ScheduleService.getNextBuses(
        ScheduleService.sitioToCentro,
        _now,
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DirectionCard(
            title: 'CENTRO → SÍTIO FLORESTA',
            nextBuses: nextCentroToSitio,
            now: _now,
          ),
          DirectionCard(
            title: 'SÍTIO FLORESTA → CENTRO',
            nextBuses: nextSitioToCentro,
            now: _now,
          ),
        ],
      );
    } catch (_) {
      return const _ErrorCard(
        message: 'Não foi possível carregar os horários no momento.',
      );
    }
  }
}

class _WeekendNotice extends StatelessWidget {
  final VoidCallback onOpenSite;

  const _WeekendNotice({required this.onOpenSite});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.weekend_rounded,
            size: 34,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          const Text(
            'Não há horários disponíveis para hoje no app.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Horários disponíveis de segunda a sexta-feira.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Consulte o site:',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: onOpenSite,
            child: Text(
              _horariosSiteUrl,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: theme.colorScheme.onErrorContainer),
      ),
    );
  }
}
