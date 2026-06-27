import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapiafrontend/features/posts/data/services/posts_api.dart';
import 'package:mapiafrontend/features/profile/domain/repositories/profile_repository.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';

class CreatePostProvider extends ChangeNotifier {
  CreatePostProvider({
    required ProfileRepository profileRepository,
    required PostsApi postsApi,
  }) : _profileRepository = profileRepository,
       _postsApi = postsApi {
    loadPublishingEligibility();
  }

  final ProfileRepository _profileRepository;
  final PostsApi _postsApi;

  String title = '';
  String description = '';
  PostType selectedType = PostType.novelty;
  XFile? image;
  bool usesCurrentLocation = false;
  double? latitude;
  double? longitude;
  String? address;
  int radiusMeters = 0;
  bool isLoading = false;
  bool isCheckingProfile = true;
  bool canPublish = false;
  bool phoneVerified = false;
  bool hasValidationError = false;
  bool hasPhoneVerificationError = false;
  bool hasLocationError = false;
  String? errorMessage;
  bool success = false;
  String? createdPostId;

  Future<void> loadPublishingEligibility() async {
    isCheckingProfile = true;
    notifyListeners();

    try {
      final profile = await _profileRepository.getProfile();
      phoneVerified = profile.phoneVerified;
      canPublish = profile.canPublish;
    } catch (_) {
      phoneVerified = false;
      canPublish = false;
    } finally {
      isCheckingProfile = false;
      notifyListeners();
    }
  }

  void updateTitle(String value) {
    title = value;
    hasValidationError = false;
    hasPhoneVerificationError = false;
    notifyListeners();
  }

  void updateDescription(String value) {
    description = value;
    hasValidationError = false;
    hasPhoneVerificationError = false;
    notifyListeners();
  }

  void selectType(PostType type) {
    selectedType = type;
    notifyListeners();
  }

  void setImage(XFile? value) {
    image = value;
    notifyListeners();
  }

  void useCurrentLocation() {
    usesCurrentLocation = true;
    hasLocationError = false;
    notifyListeners();
  }

  /// Recibe la selección del EventLocationPicker (mapa/búsqueda/radio).
  void setLocation({
    required double latitude,
    required double longitude,
    String? address,
    required int radiusMeters,
  }) {
    this.latitude = latitude;
    this.longitude = longitude;
    this.address = address;
    this.radiusMeters = radiusMeters;
    usesCurrentLocation = true;
    hasLocationError = false;
    notifyListeners();
  }

  Future<bool> submit() async {
    await loadPublishingEligibility();
    if (!canPublish) {
      hasPhoneVerificationError = true;
      notifyListeners();
      return false;
    }

    if (title.trim().isEmpty || description.trim().isEmpty) {
      hasValidationError = true;
      notifyListeners();
      return false;
    }

    isLoading = true;
    hasValidationError = false;
    hasLocationError = false;
    errorMessage = null;
    success = false;
    notifyListeners();

    final location = await _resolveLocation();
    if (location == null) {
      isLoading = false;
      hasLocationError = true;
      errorMessage =
          'No se pudo obtener tu ubicación. Actívala para publicar en el mapa.';
      notifyListeners();
      return false;
    }

    try {
      final post = await _postsApi.createPost(
        title: title.trim(),
        description: description.trim(),
        type: selectedType,
        latitude: location.lat,
        longitude: location.lng,
        address: address,
        radiusMeters: radiusMeters,
        images: image != null ? [image!] : const [],
      );
      createdPostId = post.id;
      isLoading = false;
      success = true;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = 'No se pudo publicar. Inténtalo de nuevo.';
      notifyListeners();
      return false;
    }
  }

  /// Obtiene la ubicación del dispositivo (last-known rápido, luego actual).
  Future<({double lat, double lng})?> _resolveLocation() async {
    if (latitude != null && longitude != null) {
      return (lat: latitude!, lng: longitude!);
    }
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      final pos =
          await Geolocator.getLastKnownPosition() ??
          await Geolocator.getCurrentPosition();
      return (lat: pos.latitude, lng: pos.longitude);
    } catch (_) {
      return null;
    }
  }
}
