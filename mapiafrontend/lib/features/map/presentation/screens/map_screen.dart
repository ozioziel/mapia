import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mapiafrontend/core/theme/app_theme.dart';
import 'package:mapiafrontend/features/map/services/map_api.dart';
import 'package:mapiafrontend/features/map/services/reports_api.dart';
import 'package:mapiafrontend/features/map/types/alert_map_types.dart';
import 'package:mapiafrontend/features/map/utils/bolivia_bounds.dart';
import 'package:mapiafrontend/features/map/utils/severity.dart';
import 'package:mapiafrontend/shared/widgets/app_surface.dart';
import 'package:mapiafrontend/shared/widgets/mapia_bottom_navigation.dart';
import 'package:speech_to_text/speech_to_text.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapApi = MapApi();
  final _reportsApi = ReportsApi();

  GoogleMapController? _mapController;
  AlertFilters _filters = const AlertFilters();
  AlertFilterOptions _filterOptions = const AlertFilterOptions();
  AlertMapSummary _summary = AlertMapSummary.empty();
  List<AlertMapItem> _alerts = [];
  AlertMapItem? _selected;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts({String? selectId}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _mapApi.fetchAlerts(_filters),
        _mapApi.fetchSummary(_filters),
        _mapApi.fetchFilters(),
      ]);
      final alerts = results[0] as List<AlertMapItem>;
      final summary = results[1] as AlertMapSummary;
      final options = results[2] as AlertFilterOptions;
      final selected = selectId == null
          ? _findAlert(alerts, _selected?.id) ??
                (alerts.isEmpty ? null : alerts.first)
          : _findAlert(alerts, selectId);

      if (!mounted) return;
      setState(() {
        _alerts = alerts;
        _summary = summary;
        _filterOptions = options;
        _selected = selected;
        _isLoading = false;
      });

      if (selected != null) {
        await _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(selected.position, 12.5),
        );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters(AlertFilters filters) {
    setState(() => _filters = filters);
    _loadAlerts();
  }

  void _selectAlertFromMap(AlertMapItem alert) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _selected = alert);
    });
  }

  Future<void> _openPublishReport() async {
    final id = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PublishReportSheet(reportsApi: _reportsApi),
    );
    if (id == null || id.isEmpty) return;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reporte publicado correctamente')),
    );
    await _loadAlerts(selectId: id);
  }

  void _onBottomNavTap(int index) {
    if (index == 0) return;
    if (index == 1) Navigator.of(context).pushReplacementNamed('/publications');
    if (index == 2) _openPublishReport();
    if (index == 3) Navigator.of(context).pushReplacementNamed('/alerts');
    if (index == 4) Navigator.of(context).pushReplacementNamed('/profile');
  }

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);
    final compact = viewport.width < 820;
    final compactMapHeight = (viewport.height * 0.46)
        .clamp(320.0, 440.0)
        .toDouble();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      bottomNavigationBar: MapiaBottomNavigation(
        currentIndex: 0,
        onIndexChanged: _onBottomNavTap,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openPublishReport,
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text('Publicar reporte'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadAlerts,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: _Header(summary: _summary),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SummaryCards(summary: _summary),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 104),
                  child: compact
                      ? Column(
                          children: [
                            SizedBox(
                              height: compactMapHeight,
                              child: _MapCard(
                                alerts: _alerts,
                                selected: _selected,
                                isLoading: _isLoading,
                                error: _error,
                                onMapCreated: (controller) =>
                                    _mapController = controller,
                                onAlertSelected: _selectAlertFromMap,
                                onRetry: _loadAlerts,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _SidePanel(
                              filters: _filters,
                              options: _filterOptions,
                              selected: _selected,
                              onFiltersChanged: _applyFilters,
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 7,
                              child: _MapCard(
                                alerts: _alerts,
                                selected: _selected,
                                isLoading: _isLoading,
                                error: _error,
                                onMapCreated: (controller) =>
                                    _mapController = controller,
                                onAlertSelected: _selectAlertFromMap,
                                onRetry: _loadAlerts,
                              ),
                            ),
                            const SizedBox(width: 14),
                            SizedBox(
                              width: 360,
                              child: _SidePanel(
                                filters: _filters,
                                options: _filterOptions,
                                selected: _selected,
                                onFiltersChanged: _applyFilters,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AlertMapItem? _findAlert(List<AlertMapItem> alerts, String? id) {
    if (id == null) return null;
    for (final alert in alerts) {
      if (alert.id == id) return alert;
    }
    return null;
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.summary});

  final AlertMapSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mapa de Alertas',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Monitoreo de abastecimiento, precios y reportes ciudadanos en Bolivia',
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontSize: MediaQuery.sizeOf(context).width < 420 ? 13 : 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _UpdatedPill(updatedAt: summary.updatedAt),
      ],
    );
  }
}

class _UpdatedPill extends StatelessWidget {
  const _UpdatedPill({required this.updatedAt});

  final DateTime updatedAt;

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay.fromDateTime(updatedAt.toLocal()).format(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        'Actualizado $time',
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.summary});

  final AlertMapSummary summary;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _SummaryCardData(
        'Total de alertas',
        '${summary.totalAlerts}',
        Icons.radar_rounded,
      ),
      _SummaryCardData(
        'Alertas criticas',
        '${summary.highRiskAlerts}',
        Icons.warning_rounded,
      ),
      _SummaryCardData(
        'Producto afectado',
        summary.mostAffectedProduct ?? 'Sin datos',
        Icons.inventory_2_rounded,
      ),
      _SummaryCardData(
        'Departamento afectado',
        summary.mostAffectedDepartment ?? 'Sin datos',
        Icons.location_city_rounded,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 860 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: 92,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (context, index) => _SummaryCard(data: cards[index]),
        );
      },
    );
  }
}

class _SummaryCardData {
  const _SummaryCardData(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.data});

  final _SummaryCardData data;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(data.icon, color: const Color(0xFF2563EB), size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  const _MapCard({
    required this.alerts,
    required this.selected,
    required this.isLoading,
    required this.error,
    required this.onMapCreated,
    required this.onAlertSelected,
    required this.onRetry,
  });

  final List<AlertMapItem> alerts;
  final AlertMapItem? selected;
  final bool isLoading;
  final String? error;
  final ValueChanged<GoogleMapController> onMapCreated;
  final ValueChanged<AlertMapItem> onAlertSelected;
  final Future<void> Function({String? selectId}) onRetry;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              onMapCreated: onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: boliviaCenter,
                zoom: 5.4,
              ),
              cameraTargetBounds: CameraTargetBounds(boliviaBounds),
              minMaxZoomPreference: const MinMaxZoomPreference(5.2, 18),
              mapType: MapType.normal,
              mapToolbarEnabled: false,
              myLocationButtonEnabled: true,
              myLocationEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
              rotateGesturesEnabled: false,
              markers: _markers(),
              circles: _circles(),
              onTap: (_) {},
            ),
          ),
          if (isLoading)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x66FFFFFF),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          if (!isLoading && error != null)
            Positioned(
              left: 14,
              right: 14,
              top: 14,
              child: _MapNotice(
                icon: Icons.cloud_off_rounded,
                title: 'Sin conexion al backend',
                message: error!,
                action: 'Reintentar',
                onAction: () => onRetry(),
              ),
            ),
          if (!isLoading && error == null && alerts.isEmpty)
            const Positioned(
              left: 14,
              right: 14,
              top: 14,
              child: _MapNotice(
                icon: Icons.map_outlined,
                title: 'Sin alertas por ahora',
                message: 'El mapa esta listo para mostrar nuevos reportes.',
              ),
            ),
          const Positioned(left: 14, bottom: 14, child: _Legend()),
        ],
      ),
    );
  }

  Set<Marker> _markers() {
    return {
      for (final alert in alerts)
        Marker(
          markerId: MarkerId(alert.id),
          position: alert.position,
          infoWindow: InfoWindow(title: alert.title, snippet: alert.product),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            markerHue(alert.severity),
          ),
          onTap: () => onAlertSelected(alert),
        ),
    };
  }

  Set<Circle> _circles() {
    return {
      for (final alert in alerts)
        Circle(
          circleId: CircleId('circle_${alert.id}'),
          center: alert.position,
          radius: selected?.id == alert.id ? 760 : 520,
          fillColor: severityColor(
            alert.severity,
          ).withValues(alpha: selected?.id == alert.id ? 0.32 : 0.22),
          strokeColor: Colors.white,
          strokeWidth: selected?.id == alert.id ? 4 : 3,
          consumeTapEvents: true,
          onTap: () => onAlertSelected(alert),
        ),
    };
  }
}

class _MapStateMessage extends StatelessWidget {
  const _MapStateMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 42, color: const Color(0xFF64748B)),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (action != null && onAction != null) ...[
                const SizedBox(height: 14),
                FilledButton(onPressed: onAction, child: Text(action!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MapNotice extends StatelessWidget {
  const _MapNotice({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (action != null && onAction != null) ...[
            const SizedBox(width: 8),
            TextButton(onPressed: onAction, child: Text(action!)),
          ],
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: AlertSeverity.values
            .map(
              (severity) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: severityColor(severity),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      severity.label,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SidePanel extends StatelessWidget {
  const _SidePanel({
    required this.filters,
    required this.options,
    required this.selected,
    required this.onFiltersChanged,
  });

  final AlertFilters filters;
  final AlertFilterOptions options;
  final AlertMapItem? selected;
  final ValueChanged<AlertFilters> onFiltersChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PanelTitle(
              title: 'Filtros',
              action: filters.isEmpty
                  ? null
                  : TextButton(
                      onPressed: () => onFiltersChanged(const AlertFilters()),
                      child: const Text('Limpiar filtros'),
                    ),
            ),
            const SizedBox(height: 10),
            _StringFilter(
              label: 'Departamento',
              value: filters.department,
              values: options.departments,
              onChanged: (value) => onFiltersChanged(
                filters.copyWith(
                  department: value,
                  clearDepartment: value == null,
                ),
              ),
            ),
            _StringFilter(
              label: 'Municipio',
              value: filters.municipality,
              values: options.municipalities,
              onChanged: (value) => onFiltersChanged(
                filters.copyWith(
                  municipality: value,
                  clearMunicipality: value == null,
                ),
              ),
            ),
            _StringFilter(
              label: 'Producto',
              value: filters.product,
              values: options.products,
              onChanged: (value) => onFiltersChanged(
                filters.copyWith(product: value, clearProduct: value == null),
              ),
            ),
            _EnumFilter<AlertType>(
              label: 'Tipo de problema',
              value: filters.alertType,
              values: options.alertTypes.isEmpty
                  ? AlertType.values
                  : options.alertTypes,
              labelOf: (value) => value.label,
              onChanged: (value) => onFiltersChanged(
                filters.copyWith(
                  alertType: value,
                  clearAlertType: value == null,
                ),
              ),
            ),
            _EnumFilter<AlertSeverity>(
              label: 'Severidad',
              value: filters.severity,
              values: options.severities.isEmpty
                  ? AlertSeverity.values
                  : options.severities,
              labelOf: (value) => value.label,
              onChanged: (value) => onFiltersChanged(
                filters.copyWith(severity: value, clearSeverity: value == null),
              ),
            ),
            const SizedBox(height: 16),
            const _PanelTitle(title: 'Detalle'),
            const SizedBox(height: 10),
            selected == null
                ? const _EmptyDetail()
                : _AlertDetail(alert: selected!),
          ],
        ),
      ),
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        ?action,
      ],
    );
  }
}

class _StringFilter extends StatelessWidget {
  const _StringFilter({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<String> values;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        initialValue: values.contains(value) ? value : null,
        decoration: InputDecoration(labelText: label),
        items: [
          const DropdownMenuItem(value: null, child: Text('Todos')),
          ...values.map(
            (value) => DropdownMenuItem(value: value, child: Text(value)),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _EnumFilter<T> extends StatelessWidget {
  const _EnumFilter({
    required this.label,
    required this.value,
    required this.values,
    required this.labelOf,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<T> values;
  final String Function(T value) labelOf;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<T>(
        initialValue: values.contains(value) ? value : null,
        decoration: InputDecoration(labelText: label),
        items: [
          DropdownMenuItem<T>(value: null, child: const Text('Todos')),
          ...values.map(
            (value) =>
                DropdownMenuItem(value: value, child: Text(labelOf(value))),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _EmptyDetail extends StatelessWidget {
  const _EmptyDetail();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Selecciona un marcador para revisar producto, severidad, precio, confianza e imagenes.',
      style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700),
    );
  }
}

class _AlertDetail extends StatelessWidget {
  const _AlertDetail({required this.alert});

  final AlertMapItem alert;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: severityColor(alert.severity),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                alert.title,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        if (alert.description?.isNotEmpty == true) ...[
          const SizedBox(height: 8),
          Text(
            alert.description!,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ],
        const SizedBox(height: 12),
        _DetailRow('Producto', alert.product ?? 'No especificado'),
        _DetailRow('Tipo', alert.alertType.label),
        _DetailRow('Severidad', alert.severity.label),
        _DetailRow('Departamento', alert.department ?? 'Sin dato'),
        _DetailRow('Municipio', alert.municipality ?? 'Sin dato'),
        _DetailRow('Zona', alert.zone ?? 'Sin dato'),
        _DetailRow('Reportes', '${alert.reportsCount}'),
        _DetailRow('Confianza', '${(alert.confidence * 100).round()}%'),
        _DetailRow(
          'Precio promedio',
          alert.avgPrice == null ? 'Sin dato' : '${alert.avgPrice} Bs',
        ),
        if (alert.images.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: alert.images.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  alert.images[index],
                  width: 86,
                  height: 76,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 128,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PublishReportSheet extends StatefulWidget {
  const _PublishReportSheet({required this.reportsApi});

  final ReportsApi reportsApi;

  @override
  State<_PublishReportSheet> createState() => _PublishReportSheetState();
}

class _PublishReportSheetState extends State<_PublishReportSheet> {
  final _picker = ImagePicker();
  final _speech = SpeechToText();
  final _sourceController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _productController = TextEditingController();
  final _priceController = TextEditingController();
  final _departmentController = TextEditingController();
  final _municipalityController = TextEditingController();
  final _zoneController = TextEditingController();

  AlertType _alertType = AlertType.stockBajo;
  AlertSeverity _severity = AlertSeverity.medium;
  LatLng _location = boliviaCenter;
  double _confidence = 0.75;
  List<XFile> _images = [];
  bool _isParsing = false;
  bool _isPublishing = false;
  bool _isListening = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _requestLocation();
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _productController.dispose();
    _priceController.dispose();
    _departmentController.dispose();
    _municipalityController.dispose();
    _zoneController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _requestLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      if (!isInsideBolivia(position.latitude, position.longitude)) return;
      _setLocation(LatLng(position.latitude, position.longitude));
    } catch (_) {
      return;
    }
  }

  void _setLocation(LatLng location) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _location = location);
    });
  }

  Future<void> _toggleVoice() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    final available = await _speech.initialize();
    if (!available) {
      setState(() => _error = 'No se pudo iniciar el dictado por voz');
      return;
    }

    setState(() {
      _isListening = true;
      _error = null;
    });
    await _speech.listen(
      listenOptions: SpeechListenOptions(localeId: 'es_BO'),
      onResult: (result) {
        setState(() => _sourceController.text = result.recognizedWords);
      },
    );
  }

  Future<void> _parseReport() async {
    final text = _sourceController.text.trim();
    if (text.length < 5) {
      setState(() => _error = 'Escribe o dicta un reporte primero');
      return;
    }

    setState(() {
      _isParsing = true;
      _error = null;
    });

    try {
      final parsed = await widget.reportsApi.parseReport(
        text: text,
        latitude: _location.latitude,
        longitude: _location.longitude,
      );
      setState(() {
        _titleController.text = parsed.title;
        _descriptionController.text = parsed.description;
        _productController.text = parsed.product;
        _priceController.text = parsed.price?.toString() ?? '';
        _departmentController.text = parsed.department ?? '';
        _municipalityController.text = parsed.municipality ?? '';
        _zoneController.text = parsed.zone ?? '';
        _alertType = parsed.alertType;
        _severity = parsed.severity;
        _confidence = parsed.confidence;
        _isParsing = false;
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
        _isParsing = false;
      });
    }
  }

  Future<void> _pickImages() async {
    final remaining = 3 - _images.length;
    if (remaining <= 0) return;
    final picked = await _picker.pickMultiImage(limit: remaining);
    final valid = <XFile>[];
    for (final image in picked) {
      final bytes = await image.length();
      final lower = image.name.toLowerCase();
      final allowed =
          lower.endsWith('.jpg') ||
          lower.endsWith('.jpeg') ||
          lower.endsWith('.png') ||
          lower.endsWith('.webp');
      if (bytes <= 5 * 1024 * 1024 && allowed) valid.add(image);
    }
    setState(() {
      _images = [..._images, ...valid].take(3).toList();
      if (valid.length != picked.length) {
        _error = 'Algunas imagenes fueron omitidas por formato o tamano';
      }
    });
  }

  Future<void> _publish() async {
    final title = _titleController.text.trim();
    if (title.length < 3) {
      setState(() => _error = 'El titulo es obligatorio');
      return;
    }
    if (!isInsideBolivia(_location.latitude, _location.longitude)) {
      setState(() => _error = 'La ubicacion debe estar dentro de Bolivia');
      return;
    }

    setState(() {
      _isPublishing = true;
      _error = null;
    });

    try {
      final id = await widget.reportsApi.publishReport(
        PublishReportInput(
          title: title,
          description: _descriptionController.text.trim(),
          product: _productController.text.trim(),
          alertType: _alertType,
          severity: _severity,
          latitude: _location.latitude,
          longitude: _location.longitude,
          department: _departmentController.text.trim(),
          municipality: _municipalityController.text.trim(),
          zone: _zoneController.text.trim(),
          price: double.tryParse(_priceController.text.replaceAll(',', '.')),
          sourceText: _sourceController.text.trim(),
          confidence: _confidence,
          images: _images,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(id);
    } catch (error) {
      setState(() {
        _error = error.toString();
        _isPublishing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.94,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          14,
          16,
          MediaQuery.viewInsetsOf(context).bottom + 18,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Publicar reporte',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _sourceController,
              minLines: 4,
              maxLines: 7,
              decoration: const InputDecoration(
                labelText: 'Escribir reporte',
                hintText: 'En el mercado Rodriguez el azucar subio a 9 Bs...',
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _toggleVoice,
                    icon: Icon(
                      _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                    ),
                    label: Text(
                      _isListening ? 'Detener dictado' : 'Dictar con voz',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isParsing ? null : _parseReport,
                    icon: _isParsing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome_rounded),
                    label: const Text('Analizar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SheetSection(
              title: 'Datos detectados',
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Titulo'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descriptionController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Descripcion'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _productController,
                          decoration: const InputDecoration(
                            labelText: 'Producto',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Precio Bs',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<AlertType>(
                    initialValue: _alertType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de alerta',
                    ),
                    items: AlertType.values
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _alertType = value ?? _alertType),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<AlertSeverity>(
                    initialValue: _severity,
                    decoration: const InputDecoration(labelText: 'Severidad'),
                    items: AlertSeverity.values
                        .map(
                          (severity) => DropdownMenuItem(
                            value: severity,
                            child: Text(severity.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _severity = value ?? _severity),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _departmentController,
                    decoration: const InputDecoration(
                      labelText: 'Departamento',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _municipalityController,
                    decoration: const InputDecoration(labelText: 'Municipio'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _zoneController,
                    decoration: const InputDecoration(labelText: 'Zona'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SheetSection(
              title: 'Ubicacion',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 220,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _location,
                          zoom: 13,
                        ),
                        cameraTargetBounds: CameraTargetBounds(
                          boliviaBounds,
                        ),
                        minMaxZoomPreference: const MinMaxZoomPreference(
                          5.2,
                          18,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('report_location'),
                            position: _location,
                            draggable: true,
                            onDragEnd: _setLocation,
                          ),
                        },
                        onTap: _setLocation,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lat ${_location.latitude.toStringAsFixed(5)}, Lng ${_location.longitude.toStringAsFixed(5)}',
                    style: TextStyle(
                      color:
                          isInsideBolivia(
                            _location.latitude,
                            _location.longitude,
                          )
                          ? const Color(0xFF64748B)
                          : const Color(0xFFEF4444),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _requestLocation,
                    icon: const Icon(Icons.my_location_rounded),
                    label: const Text('Usar ubicacion actual'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SheetSection(
              title: 'Imagenes',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OutlinedButton.icon(
                    onPressed: _images.length >= 3 ? null : _pickImages,
                    icon: const Icon(Icons.photo_library_rounded),
                    label: const Text('Agregar imagenes'),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final image in _images)
                        _ImagePreview(
                          image: image,
                          onRemove: () => setState(
                            () => _images = _images
                                .where((item) => item != image)
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isPublishing ? null : _publish,
              icon: _isPublishing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.publish_rounded),
              label: const Text('Publicar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetSection extends StatelessWidget {
  const _SheetSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.image, required this.onRemove});

  final XFile image;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: image.readAsBytes(),
      builder: (context, snapshot) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: snapshot.hasData
                  ? Image.memory(
                      snapshot.data!,
                      width: 86,
                      height: 86,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 86,
                      height: 86,
                      color: const Color(0xFFE2E8F0),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: IconButton.filledTonal(
                onPressed: onRemove,
                icon: const Icon(Icons.close_rounded, size: 16),
                constraints: const BoxConstraints.tightFor(
                  width: 30,
                  height: 30,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        );
      },
    );
  }
}
