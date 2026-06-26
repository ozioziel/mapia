import 'package:flutter/foundation.dart';
import 'package:mapiafrontend/features/profile/data/datasources/profile_mock_datasource.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';

class CreatePostProvider extends ChangeNotifier {
  CreatePostProvider({ProfileMockDatasource? profileDatasource})
    : _profileDatasource = profileDatasource ?? ProfileMockDatasource() {
    loadPublishingEligibility();
  }

  final ProfileMockDatasource _profileDatasource;

  String title = '';
  String description = '';
  PostType selectedType = PostType.novelty;
  String? imageSource;
  bool usesCurrentLocation = false;
  bool isLoading = false;
  bool isCheckingProfile = true;
  bool canPublish = false;
  bool phoneVerified = false;
  bool hasValidationError = false;
  bool hasPhoneVerificationError = false;
  bool success = false;

  Future<void> loadPublishingEligibility() async {
    isCheckingProfile = true;
    notifyListeners();

    final profile = await _profileDatasource.getProfile();
    phoneVerified = profile.phoneVerified;
    canPublish = profile.canPublish;
    isCheckingProfile = false;
    notifyListeners();
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

  void selectImageSource(String source) {
    imageSource = source;
    notifyListeners();
  }

  void useCurrentLocation() {
    usesCurrentLocation = true;
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
    success = false;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 650));

    isLoading = false;
    success = true;
    notifyListeners();
    return true;
  }
}
