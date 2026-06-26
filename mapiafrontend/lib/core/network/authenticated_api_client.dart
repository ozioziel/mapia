import 'package:mapiafrontend/core/network/api_client.dart';
import 'package:mapiafrontend/features/auth/presentation/providers/auth_provider.dart';

ApiClient createAuthenticatedApiClient(AuthProvider auth) {
  return ApiClient(
    accessTokenProvider: () => auth.accessToken,
    onUnauthorized: auth.refreshAccessToken,
  );
}
