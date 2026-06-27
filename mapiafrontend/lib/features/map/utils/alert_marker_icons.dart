import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapiafrontend/features/map/types/alert_map_types.dart';
import 'package:mapiafrontend/features/map/utils/severity.dart';

class AlertMapMarkerIcons {
  AlertMapMarkerIcons._(this._icons, this._mineIcons);

  final Map<AlertType, BitmapDescriptor> _icons;
  final Map<AlertType, BitmapDescriptor> _mineIcons;

  BitmapDescriptor iconFor(AlertType type, {required bool isMine}) {
    final source = isMine ? _mineIcons : _icons;
    return source[type] ??
        BitmapDescriptor.defaultMarkerWithHue(
          isMine ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueOrange,
        );
  }

  static Future<AlertMapMarkerIcons> create() async {
    final normalEntries = await Future.wait(
      AlertType.values.map((type) async {
        return MapEntry(type, await _createIcon(type, isMine: false));
      }),
    );
    final mineEntries = await Future.wait(
      AlertType.values.map((type) async {
        return MapEntry(type, await _createIcon(type, isMine: true));
      }),
    );

    return AlertMapMarkerIcons._(
      Map.fromEntries(normalEntries),
      Map.fromEntries(mineEntries),
    );
  }

  static Future<BitmapDescriptor> _createIcon(
    AlertType type, {
    required bool isMine,
  }) async {
    const double size = 112;
    const double center = size / 2;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final iconData = _iconFor(type);
    final fillColor = isMine
        ? const Color(0xFF2563EB)
        : severityColor(_defaultSeverity(type));

    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 10);
    canvas.drawCircle(const Offset(center, center + 6), 38, shadow);

    canvas.drawCircle(
      const Offset(center, center),
      39,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      const Offset(center, center),
      31,
      Paint()..color = fillColor,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          color: Colors.white,
          fontSize: 36,
          fontFamily: iconData.fontFamily,
          package: iconData.fontPackage,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(center - textPainter.width / 2, center - textPainter.height / 2),
    );

    if (isMine) {
      canvas.drawCircle(
        const Offset(center + 24, center - 24),
        10,
        Paint()..color = const Color(0xFF0F172A),
      );
      final badgePainter = TextPainter(
        text: const TextSpan(
          text: 'M',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      badgePainter.paint(
        canvas,
        Offset(center + 24 - badgePainter.width / 2, center - 24 - 7),
      );
    }

    final image = await recorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final data = bytes?.buffer.asUint8List() ?? Uint8List(0);
    return BitmapDescriptor.bytes(data, width: 54, height: 54);
  }

  static IconData _iconFor(AlertType type) {
    return switch (type) {
      AlertType.stockBajo => Icons.inventory_2_rounded,
      AlertType.sobreprecio => Icons.trending_up_rounded,
      AlertType.bloqueo => Icons.block_rounded,
      AlertType.retrasoProveedor => Icons.local_shipping_rounded,
      AlertType.combustible => Icons.local_gas_station_rounded,
      AlertType.productoNoDisponible => Icons.store_mall_directory_rounded,
      AlertType.otro => Icons.report_problem_rounded,
    };
  }

  static AlertSeverity _defaultSeverity(AlertType type) {
    return switch (type) {
      AlertType.bloqueo => AlertSeverity.high,
      AlertType.combustible => AlertSeverity.high,
      AlertType.sobreprecio => AlertSeverity.medium,
      AlertType.retrasoProveedor => AlertSeverity.medium,
      AlertType.stockBajo => AlertSeverity.low,
      AlertType.productoNoDisponible => AlertSeverity.high,
      AlertType.otro => AlertSeverity.normal,
    };
  }
}
