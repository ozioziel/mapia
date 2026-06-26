import 'package:flutter/widgets.dart';
import 'package:mapiafrontend/core/network/authenticated_api_client.dart';
import 'package:mapiafrontend/features/auth/presentation/widgets/auth_gate.dart';
import 'package:mapiafrontend/features/profile/data/datasources/profile_api.dart';
import 'package:mapiafrontend/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:mapiafrontend/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:mapiafrontend/features/profile/presentation/providers/profile_provider.dart';

ProfileProvider createProfileProvider(BuildContext context) {
  final auth = AuthScope.of(context);
  final user = auth.user;
  if (user == null) {
    throw StateError('Se requiere una sesion activa para cargar el perfil.');
  }

  final client = createAuthenticatedApiClient(auth);
  final datasource = ProfileRemoteDatasource(
    api: ProfileApi(client: client),
    userEmail: user.email,
    userId: user.id,
  );

  return ProfileProvider(
    repository: ProfileRepositoryImpl(datasource),
  );
}
