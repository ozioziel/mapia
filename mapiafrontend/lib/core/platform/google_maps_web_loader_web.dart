// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;

import 'package:mapiafrontend/core/config/app_config.dart';

Completer<void>? _loader;

Future<void> ensureGoogleMapsWebLoaded() {
  if (AppConfig.googleMapsApiKey.isEmpty) {
    return Future.value();
  }

  final existing = html.document.getElementById('google-maps-sdk');
  if (existing != null) return _loader?.future ?? Future.value();

  final completer = _loader ??= Completer<void>();
  final script = html.ScriptElement()
    ..id = 'google-maps-sdk'
    ..async = true
    ..defer = true
    ..src =
        'https://maps.googleapis.com/maps/api/js?key=${Uri.encodeComponent(AppConfig.googleMapsApiKey)}';

  script.onLoad.first.then((_) {
    if (!completer.isCompleted) completer.complete();
  });
  script.onError.first.then((_) {
    if (!completer.isCompleted) {
      completer.completeError('No se pudo cargar Google Maps');
    }
  });

  html.document.head?.append(script);
  return completer.future;
}
