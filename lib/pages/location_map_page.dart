import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:projeto_flutter/models/geo_point.dart';
import 'package:projeto_flutter/services/location_service.dart';

class LocationMapPage extends StatefulWidget {
  final GeoPoint? initialLocation;
  final String title;
  final bool selectable;
  final Function(GeoPoint)? onLocationSelected;

  const LocationMapPage({
    Key? key,
    this.initialLocation,
    required this.title,
    this.selectable = false,
    this.onLocationSelected,
  }) : super(key: key);

  @override
  State<LocationMapPage> createState() => _LocationMapPageState();
}

class _LocationMapPageState extends State<LocationMapPage> {
  final LocationService _locationService = LocationService();
  late MapController _mapController;
  GeoPoint? _selectedLocation;
  String _address = 'Carregando endereço...';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLocation = widget.initialLocation;
    if (_selectedLocation != null) {
      _loadAddress();
    }
  }

  Future<void> _loadAddress() async {
    if (_selectedLocation == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final address = await _locationService.getAddressFromCoordinates(_selectedLocation!);
      setState(() {
        _address = address;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _address = 'Erro ao carregar endereço';
        _isLoading = false;
      });
    }
  }

  void _handleTap(TapPosition tapPosition, LatLng point) {
    if (!widget.selectable) return;

    final newLocation = GeoPoint(
      latitude: point.latitude,
      longitude: point.longitude,
    );

    setState(() {
      _selectedLocation = newLocation;
      _address = 'Carregando endereço...';
    });

    _loadAddress();
  }

  void _confirmLocation() {
    if (_selectedLocation != null && widget.onLocationSelected != null) {
      widget.onLocationSelected!(_selectedLocation!);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: widget.selectable
            ? [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: _selectedLocation != null ? _confirmLocation : null,
                  tooltip: 'Confirmar localização',
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedLocation != null
                    ? LatLng(_selectedLocation!.latitude, _selectedLocation!.longitude)
                    : const LatLng(-23.5505, -46.6333), // São Paulo como padrão
                initialZoom: 13.0,
                onTap: widget.selectable ? _handleTap : null,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                if (_selectedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(_selectedLocation!.latitude, _selectedLocation!.longitude),
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedLocation != null) ...[
                  Text(
                    'Coordenadas:',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _locationService.formatCoordinates(_selectedLocation!),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Endereço:',
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  _isLoading
                      ? const LinearProgressIndicator()
                      : Text(
                          _address,
                          style: theme.textTheme.bodyMedium,
                        ),
                ] else if (widget.selectable) ...[
                  Text(
                    'Toque no mapa para selecionar uma localização',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (widget.selectable) ...[
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _selectedLocation != null ? _confirmLocation : null,
                    icon: const Icon(Icons.check),
                    label: const Text('Confirmar Localização'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
