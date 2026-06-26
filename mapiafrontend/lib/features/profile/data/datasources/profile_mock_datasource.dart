import 'package:mapiafrontend/features/profile/data/models/profile_model.dart';

class ProfileMockDatasource {
  ProfileMockDatasource();

  static ProfileModel _profile = ProfileModel(
    id: 'user-daniel-rojas',
    name: 'Daniel Rojas',
    username: '@daniel.mapia',
    bio: 'Explorando La Paz y compartiendo lo que pasa cerca.',
    avatarUrl: null,
    followersCount: 320,
    followingCount: 180,
    likesCount: 1240,
    postsCount: 12,
    location: 'La Paz, Bolivia',
    createdAt: DateTime(2026, 1, 12),
    posts: const [
      ProfilePostModel(
        id: 'food-01',
        title: 'Pollo barato cerca de la plaza',
        subtitle: 'Comida barata en Sopocachi',
        likesCount: 24,
      ),
      ProfilePostModel(
        id: 'event-01',
        title: 'Fiesta universitaria este viernes',
        subtitle: 'Evento cerca de la UMSA',
        likesCount: 76,
      ),
      ProfilePostModel(
        id: 'blockade-01',
        title: 'Bloqueo parcial en la Pérez Velasco',
        subtitle: 'Tránsito lento hacia el centro',
        likesCount: 41,
      ),
      ProfilePostModel(
        id: 'sale-01',
        title: 'Venta de salteñas económicas',
        subtitle: 'Venta temporal en El Prado',
        likesCount: 19,
      ),
    ],
  );

  Future<ProfileModel> getProfile() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _profile;
  }

  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _profile = profile;
    return _profile;
  }

  Future<void> clearSession() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
  }
}
