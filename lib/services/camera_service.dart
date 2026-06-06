import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CameraService {
  final ImagePicker _picker = ImagePicker();
  String? _lastPhotoPath;

  String? get lastPhotoPath => _lastPhotoPath;

  Future<String?> takeSelfie() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 85,
      );

      if (photo != null) {
        _lastPhotoPath = photo.path;
        debugPrint('Selfie taken: ${photo.path}');
        return photo.path;
      }
      return null;
    } catch (e) {
      debugPrint('Camera error: $e');
      return null;
    }
  }

  Future<String?> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
      );

      if (photo != null) {
        _lastPhotoPath = photo.path;
        debugPrint('Photo taken: ${photo.path}');
        return photo.path;
      }
      return null;
    } catch (e) {
      debugPrint('Camera error: $e');
      return null;
    }
  }

  Future<String?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        _lastPhotoPath = image.path;
        debugPrint('Image picked: ${image.path}');
        return image.path;
      }
      return null;
    } catch (e) {
      debugPrint('Gallery error: $e');
      return null;
    }
  }

  Future<bool> deleteLastPhoto() async {
    if (_lastPhotoPath == null) return false;
    
    try {
      final file = File(_lastPhotoPath!);
      if (await file.exists()) {
        await file.delete();
        debugPrint('Photo deleted: $_lastPhotoPath');
        _lastPhotoPath = null;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Delete error: $e');
      return false;
    }
  }

  void dispose() {
    debugPrint('Camera Service disposed');
  }
}
