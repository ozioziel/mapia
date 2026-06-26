import 'package:flutter/foundation.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';

class CreatePostProvider extends ChangeNotifier {
  String title = '';
  String description = '';
  PostType selectedType = PostType.novelty;
  String? imageSource;
  bool usesCurrentLocation = false;
  bool isLoading = false;
  bool hasValidationError = false;
  bool success = false;

  void updateTitle(String value) {
    title = value;
    hasValidationError = false;
    notifyListeners();
  }

  void updateDescription(String value) {
    description = value;
    hasValidationError = false;
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
