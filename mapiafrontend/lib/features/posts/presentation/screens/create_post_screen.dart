import 'package:flutter/material.dart';
import 'package:mapiafrontend/core/localization/l10n_extension.dart';
import 'package:mapiafrontend/core/network/authenticated_api_client.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/auth/presentation/widgets/auth_gate.dart';
import 'package:mapiafrontend/features/profile/data/datasources/profile_api.dart';
import 'package:mapiafrontend/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:mapiafrontend/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:mapiafrontend/features/posts/data/services/posts_api.dart';
import 'package:mapiafrontend/features/posts/presentation/providers/create_post_provider.dart';
import 'package:mapiafrontend/features/posts/presentation/widgets/create_post_form.dart';
import 'package:mapiafrontend/shared/widgets/app_surface.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  CreatePostProvider? _provider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_provider != null) return;

    final auth = AuthScope.of(context);
    final user = auth.user;
    if (user == null) {
      return;
    }
    final client = createAuthenticatedApiClient(auth);
    final datasource = ProfileRemoteDatasource(
      api: ProfileApi(client: client),
      userEmail: user.email,
      userId: user.id,
    );
    _provider = CreatePostProvider(
      profileRepository: ProfileRepositoryImpl(datasource),
      postsApi: PostsApi(client: client),
    );
  }

  @override
  void dispose() {
    _provider?.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final created = await _provider?.submit() ?? false;
    if (!mounted || !created) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.postCreatedSuccessfully),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop();
  }

  Future<void> _openVerifyPhone() async {
    await Navigator.of(context).pushNamed('/profile/verify-phone');
    if (mounted) {
      _provider?.loadPublishingEligibility();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppGradientScaffold(
      appBar: AppBar(title: Text(context.l10n.createPost)),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _provider ?? Listenable.merge(const []),
          builder: (context, _) {
            final provider = _provider;
            if (provider == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              child: AppCard(
                padding: const EdgeInsets.all(18),
                gradient: AppTheme.warmGradient,
                child: CreatePostForm(
                  provider: provider,
                  onSubmit: _submit,
                  onVerifyPhone: _openVerifyPhone,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
