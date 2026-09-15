import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/schedule_service.dart';
import '../widgets/app_header.dart';
import '../widgets/route_block.dart';
import '../widgets/section_header.dart';

const String _horariosSiteUrl = 'https://www.portalprati.com.br/pelotas/horarios';

const Color _colorSitioCentro = Color(0xFF1E8E5A); // bloco 1 (verde)
const Color _colorCentroUfpel = Color(0xFF2F6FB0); // bloco 2 (azul)
const Color _colorUfpelCentro = Color(0xFF7C5CBF); // bloco 3 (roxo)
const Color _colorCentroSitio = Color(0xFFC97B2E); // bloco 4 (laranja)
const Color _colorSecaoIda = Color(0xFF1E8E5A);
const Color _colorSecaoVolta = Color(0xFF7C5CBF);
const Color _corBotaoAtualizar = Color(0xFF0B3D78);

/// Tela unica do aplicativo: cabecalho com relogio e, para dias uteis,
/// as quatro etapas da rota diaria (ida para a faculdade e volta para
/// casa), ou o aviso de fim de semana. Atualiza automaticamente a cada
/// segundo atraves de um unico Timer centralizado.
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
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(now: _now),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_errorMessage != null)
                      _ErrorCard(message: _errorMessage!)
                    else if (!ScheduleService.isWeekday(_now))
                      _WeekendNotice(onOpenSite: _openHorariosSite)
                    else
                      _buildRoutes(),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Atualizar horários'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _corBotaoAtualizar,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildFooterInfo(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutes() {
    try {
      final lastSitioCentro =
          ScheduleService.getLastBus(ScheduleService.sitioToCentro, _now);
      final nextSitioCentro =
          ScheduleService.getNextBuses(ScheduleService.sitioToCentro, _now);
      final lastCentroUfpel =
          ScheduleService.getLastBus(ScheduleService.centroToUfpel, _now);
      final nextCentroUfpel =
          ScheduleService.getNextBuses(ScheduleService.centroToUfpel, _now);
      final lastUfpelCentro =
          ScheduleService.getLastBus(ScheduleService.ufpelToCentro, _now);
      final nextUfpelCentro =
          ScheduleService.getNextBuses(ScheduleService.ufpelToCentro, _now);
      final lastCentroSitio =
          ScheduleService.getLastBus(ScheduleService.centroToSitio, _now);
      final nextCentroSitio =
          ScheduleService.getNextBuses(ScheduleService.centroToSitio, _now);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(
            icon: Icons.home_rounded,
            title: 'IDA PARA A FACULDADE',
            subtitle: 'Da sua casa até a UFPel / Anglo',
            color: _colorSecaoIda,
          ),
          RouteBlock(
            number: 1,
            title: 'SÍTIO FLORESTA → CENTRO',
            subtitle: 'Primeira etapa: do seu bairro para o Centro',
            color: _colorSitioCentro,
            lastBus: lastSitioCentro,
            nextBuses: nextSitioCentro,
            now: _now,
          ),
          RouteBlock(
            number: 2,
            title: 'CENTRO → UFPel / ANGLO',
            subtitle: 'Segunda etapa: do Centro para a Faculdade',
            color: _colorCentroUfpel,
            lastBus: lastCentroUfpel,
            nextBuses: nextCentroUfpel,
            now: _now,
          ),
          const SectionHeader(
            icon: Icons.school_rounded,
            title: 'VOLTA PARA CASA',
            subtitle: 'Da UFPel / Anglo até o seu bairro',
            color: _colorSecaoVolta,
          ),
          RouteBlock(
            number: 3,
            title: 'UFPel / ANGLO → CENTRO',
            subtitle: 'Terceira etapa: da Faculdade para o Centro',
            color: _colorUfpelCentro,
            lastBus: lastUfpelCentro,
            nextBuses: nextUfpelCentro,
            now: _now,
          ),
          RouteBlock(
            number: 4,
            title: 'CENTRO → SÍTIO FLORESTA',
            subtitle: 'Quarta etapa: do Centro para o seu bairro',
            color: _colorCentroSitio,
            lastBus: lastCentroSitio,
            nextBuses: nextCentroSitio,
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

  Widget _buildFooterInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 18, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Horários válidos de segunda a sexta-feira. Consulte '
                  'também o site da Prati para mais informações.',
                  style: TextStyle(fontSize: 12.5, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: _openHorariosSite,
                  child: const Text(
                    _horariosSiteUrl,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: _corBotaoAtualizar,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
