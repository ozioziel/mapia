import 'package:mapiafrontend/features/profile/data/models/profile_model.dart';

class ProfileMockDatasource {
  ProfileMockDatasource();

  static ProfileModel _profile = ProfileModel(
    id: 'user-daniel-rojas',
    firstName: 'Daniel',
    lastName: 'Rojas',
    email: 'demo@mapia.app',
    phone: '+59171234567',
    phoneVerified: false,
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

  Future<ProfileModel> registerProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _profile = ProfileModel(
      id: 'user-${email.trim().toLowerCase()}',
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: email.trim().toLowerCase(),
      phone: phone.trim(),
      phoneVerified: false,
      username: '@${email.split('@').first.trim()}',
      bio: '',
      avatarUrl: null,
      followersCount: 0,
      followingCount: 0,
      likesCount: 0,
      postsCount: 0,
      location: 'La Paz, Bolivia',
      createdAt: DateTime.now(),
      posts: const [],
    );
    return _profile;
  }

  Future<ProfileModel> markPhoneVerified() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    _profile = ProfileModel.fromEntity(_profile.copyWith(phoneVerified: true));
    return _profile;
  }

  Future<void> clearSession() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
  }
}
