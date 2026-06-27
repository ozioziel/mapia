import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';
import 'package:mapiafrontend/core/localization/localized_post_type.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/core/network/authenticated_api_client.dart';
import 'package:mapiafrontend/features/auth/presentation/widgets/auth_gate.dart';
import 'package:mapiafrontend/features/posts/data/repositories/remote_post_repository.dart';
import 'package:mapiafrontend/features/posts/data/services/posts_api.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';
import 'package:mapiafrontend/features/posts/presentation/providers/post_detail_provider.dart';
import 'package:mapiafrontend/features/posts/presentation/widgets/comment_input.dart';
import 'package:mapiafrontend/features/posts/presentation/widgets/comments_section.dart';
import 'package:mapiafrontend/features/posts/presentation/widgets/post_author_header.dart';
import 'package:mapiafrontend/features/posts/presentation/widgets/post_interaction_bar.dart';
import 'package:mapiafrontend/features/posts/presentation/widgets/post_media_viewer.dart';
import 'package:mapiafrontend/features/report_candidates/data/report_candidates_api.dart';
import 'package:mapiafrontend/shared/widgets/app_surface.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.postId});

  final String postId;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  PostDetailProvider? _provider;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final auth = AuthScope.of(context);
    _provider = PostDetailProvider(
      postId: widget.postId,
      repository: RemotePostRepository(
        api: PostsApi(client: createAuthenticatedApiClient(auth)),
      ),
    )..load();
  }

  @override
  void dispose() {
    _provider?.dispose();
    super.dispose();
  }

  Future<void> _setReaction(PostReaction reaction) async {
    final ok = await _provider?.setReaction(reaction) ?? false;
    if (!ok && mounted) {
      _showMessage(_provider?.error ?? 'No se pudo guardar tu reaccion.');
    }
  }

  Future<void> _reportFalseInformation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reportar como falso'),
        content: const Text(
          'Revisaremos esta publicacion. Si ya la reportaste, no se duplicara.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reportar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await _provider?.reportFalseInformation() ?? false;
    if (!mounted) return;
    _showMessage(
      ok
          ? 'Reporte enviado.'
          : (_provider?.error ?? 'No se pudo enviar el reporte.'),
    );
  }

  Future<bool> _createComment(String content) async {
    final ok = await _provider?.createComment(content) ?? false;
    if (!ok && mounted) {
      _showMessage(_provider?.error ?? 'No se pudo comentar.');
    }
    return ok;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  void _sharePost() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(context.l10n.sharePostReady),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _markAsCandidate(PostEntity post) async {
    try {
      final auth = AuthScope.of(context);
      final api = ReportCandidatesApi(
        client: createAuthenticatedApiClient(auth),
      );
      await api.createFromPost(post.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Publicacion marcada como candidata para revision.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('No se pudo registrar el candidato: $error'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      appBar: AppBar(title: Text(context.l10n.publication)),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _provider ?? Listenable.merge(const []),
          builder: (context, _) {
            final provider = _provider;
            if (provider == null || provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null || provider.post == null) {
              return _DetailError(
                message: provider.error ?? context.l10n.postNotFound,
                onRetry: provider.load,
              );
            }

            final post = provider.post!;
            final type = post.type.option;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              child: AppCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PostAuthorHeader(post: post),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StatusBadge(isVerified: post.isVerified),
                        _TypeBadge(type: type),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      post.title,
                      style: const TextStyle(
                        color: AppTheme.textNavy,
                        fontSize: 23,
                        height: 1.12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      post.description,
                      style: const TextStyle(
                        color: Color(0xFF4F5B6B),
                        fontSize: 15.5,
                        height: 1.42,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    PostMediaViewer(post: post),
                    if (post.mediaUrl != null) const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    PostInteractionBar(
                      likesCount: post.likesCount,
                      dislikesCount: post.dislikesCount,
                      commentsCount: post.commentsCount,
                      userReaction: post.userReaction.name.toUpperCase(),
                      isBusy: provider.isMutating,
                      onLikeTap: () => _setReaction(PostReaction.like),
                      onDislikeTap: () => _setReaction(PostReaction.dislike),
                      onReportTap: _reportFalseInformation,
                      onShareTap: _sharePost,
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => _markAsCandidate(post),
                      icon: const Icon(Icons.assignment_turned_in_rounded),
                      label: const Text('Reportar como problema solucionable'),
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 18),
                    CommentsSection(comments: provider.comments),
                    const SizedBox(height: 8),
                    CommentInput(
                      isSubmitting: provider.isMutating,
                      onSubmit: _createComment,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isVerified});

  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    final color = isVerified
        ? const Color(0xFF0B8063)
        : const Color(0xFFFFA000);
    return _Pill(
      icon: isVerified ? Icons.verified_rounded : Icons.hourglass_top_rounded,
      label: isVerified ? context.l10n.verified : context.l10n.inReview,
      color: color,
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final PostTypeOption type;

  @override
  Widget build(BuildContext context) {
    return _Pill(
      icon: type.icon,
      label: type.type.label(context),
      color: type.color,
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: AppTheme.mutedText,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textNavy,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(onPressed: onRetry, child: Text(context.l10n.retry)),
          ],
        ),
      ),
    );
  }
}
