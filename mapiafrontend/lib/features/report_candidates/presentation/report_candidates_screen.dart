import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mapiafrontend/core/network/authenticated_api_client.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/auth/presentation/widgets/auth_gate.dart';
import 'package:mapiafrontend/features/report_candidates/data/report_candidates_api.dart';
import 'package:mapiafrontend/features/report_candidates/domain/report_candidate.dart';
import 'package:mapiafrontend/features/report_candidates/presentation/report_candidates_provider.dart';
import 'package:mapiafrontend/shared/widgets/app_surface.dart';

class ReportCandidatesScreen extends StatefulWidget {
  const ReportCandidatesScreen({super.key});

  @override
  State<ReportCandidatesScreen> createState() => _ReportCandidatesScreenState();
}

class _ReportCandidatesScreenState extends State<ReportCandidatesScreen> {
  ReportCandidatesProvider? _provider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_provider != null) return;
    final auth = AuthScope.of(context);
    _provider = ReportCandidatesProvider(
      api: ReportCandidatesApi(client: createAuthenticatedApiClient(auth)),
    )..load();
  }

  @override
  void dispose() {
    _provider?.dispose();
    super.dispose();
  }

  void _openPost(ReportCandidate candidate) {
    Navigator.of(
      context,
    ).pushNamed('/posts/${Uri.encodeComponent(candidate.postId)}');
  }

  void _openMap(ReportCandidate candidate) {
    Navigator.of(context).pushReplacementNamed('/map');
  }

  Future<void> _showGeneratedReport() async {
    await _provider?.generateReport();
    if (!mounted || _provider?.generatedReport == null) return;
    await showDialog<void>(
      context: context,
      builder: (context) =>
          _GeneratedReportDialog(report: _provider!.generatedReport!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      appBar: AppBar(
        title: const Text('Candidatos para Alcaldia'),
        actions: [
          IconButton(
            tooltip: 'Generar informe',
            onPressed: _showGeneratedReport,
            icon: const Icon(Icons.description_rounded),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _provider!,
        builder: (context, _) {
          final provider = _provider!;
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: provider.load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                if (provider.error != null || provider.usingMockData)
                  _Notice(
                    text: provider.error ?? 'Mostrando candidatos de prueba.',
                  ),
                const SizedBox(height: 10),
                for (final candidate in provider.candidates) ...[
                  _CandidateCard(
                    candidate: candidate,
                    onOpenPost: () => _openPost(candidate),
                    onOpenMap: () => _openMap(candidate),
                    onApprove: () => provider.updateStatus(
                      candidate.id,
                      ReportCandidateStatus.aprobadoParaInforme,
                    ),
                    onReject: () => provider.updateStatus(
                      candidate.id,
                      ReportCandidateStatus.rechazado,
                      rejectionReason: 'Rechazado desde revision admin.',
                    ),
                    onInclude: () => provider.updateStatus(
                      candidate.id,
                      ReportCandidateStatus.incluidoEnInforme,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppTheme.primaryBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.textNavy,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({
    required this.candidate,
    required this.onOpenPost,
    required this.onOpenMap,
    required this.onApprove,
    required this.onReject,
    required this.onInclude,
  });

  final ReportCandidate candidate;
  final VoidCallback onOpenPost;
  final VoidCallback onOpenMap;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onInclude;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Badge(
                icon: Icons.category_rounded,
                label: candidate.category.label,
                color: AppTheme.primaryBlue,
              ),
              _Badge(
                icon: Icons.flag_rounded,
                label: candidate.priority.label,
                color: _priorityColor(candidate.priority),
              ),
              _Badge(
                icon: Icons.fact_check_rounded,
                label: candidate.status.label,
                color: _statusColor(candidate.status),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            candidate.title,
            style: const TextStyle(
              color: AppTheme.textNavy,
              fontSize: 18,
              height: 1.16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            candidate.summary,
            style: const TextStyle(
              color: Color(0xFF4F5B6B),
              fontSize: 14,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 11),
          _MetaRow(
            icon: Icons.place_rounded,
            text: candidate.locationText ?? 'Informacion no disponible',
          ),
          _MetaRow(
            icon: Icons.people_alt_rounded,
            text:
                '${candidate.citizenSupportCount} apoyos ciudadanos - ${candidate.commentsCount} comentarios',
          ),
          _MetaRow(
            icon: Icons.event_rounded,
            text: DateFormat('dd/MM/yyyy HH:mm').format(candidate.createdAt),
          ),
          if (candidate.suggestedSolution != null) ...[
            const SizedBox(height: 8),
            Text(
              'Solucion sugerida: ${candidate.suggestedSolution}',
              style: const TextStyle(
                color: AppTheme.textNavy,
                fontSize: 13,
                height: 1.32,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 13),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onOpenPost,
                icon: const Icon(Icons.article_rounded),
                label: const Text('Ver publicacion'),
              ),
              OutlinedButton.icon(
                onPressed: onOpenMap,
                icon: const Icon(Icons.map_rounded),
                label: const Text('Ver en mapa'),
              ),
              FilledButton.icon(
                onPressed: onApprove,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Aprobar'),
              ),
              FilledButton.tonalIcon(
                onPressed: onReject,
                icon: const Icon(Icons.close_rounded),
                label: const Text('Rechazar'),
              ),
              FilledButton.tonalIcon(
                onPressed: onInclude,
                icon: const Icon(Icons.playlist_add_check_rounded),
                label: const Text('Incluir en informe'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.mutedText),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.mutedText,
                fontSize: 12.8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneratedReportDialog extends StatelessWidget {
  const _GeneratedReportDialog({required this.report});

  final GeneratedCitizenReport report;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(report.title),
      content: SizedBox(
        width: 720,
        child: SingleChildScrollView(
          child: SelectableText(
            '${report.note}\n\n${report.body}',
            style: const TextStyle(height: 1.35),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

Color _priorityColor(ReportCandidatePriority priority) {
  return switch (priority) {
    ReportCandidatePriority.baja => const Color(0xFF0B8063),
    ReportCandidatePriority.media => const Color(0xFFFFA000),
    ReportCandidatePriority.alta => const Color(0xFFE53935),
    ReportCandidatePriority.urgente => const Color(0xFF7B1FA2),
  };
}

Color _statusColor(ReportCandidateStatus status) {
  return switch (status) {
    ReportCandidateStatus.pendienteRevision => const Color(0xFFFFA000),
    ReportCandidateStatus.aprobadoParaInforme => const Color(0xFF0B8063),
    ReportCandidateStatus.rechazado => const Color(0xFFE53935),
    ReportCandidateStatus.incluidoEnInforme => const Color(0xFF1A73E8),
    ReportCandidateStatus.enviado => const Color(0xFF7B1FA2),
    ReportCandidateStatus.resuelto => const Color(0xFF607D8B),
  };
}
