import 'package:flutter/foundation.dart';
import 'package:mapiafrontend/features/posts/domain/entities/post_entity.dart';

class CreatePostProvider extends ChangeNotifier {
  String title = '';
  String description = '';
  PostType selectedType = PostType.novelty;
  String? imageSource;
  String address = 'La Paz, Bolivia - ubicación aproximada';
  bool isLoading = false;
  String? error;
  bool success = false;

  void updateTitle(String value) {
    title = value;
    error = null;
    notifyListeners();
  }

  void updateDescription(String value) {
    description = value;
    error = null;
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
    address = 'Sopocachi, La Paz - cerca de tu ubicación';
    notifyListeners();
  }

  Future<bool> submit() async {
    if (title.trim().isEmpty || description.trim().isEmpty) {
      error = 'Completa título y descripción para publicar.';
      notifyListeners();
      return false;
    }

    isLoading = true;
    error = null;
    success = false;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 650));

    isLoading = false;
    success = true;
    notifyListeners();
    return true;
  }
}
