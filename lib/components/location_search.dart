import 'dart:async';
import 'package:flutter/material.dart';
import 'package:projeto_flutter/models/geo_point.dart';
import 'package:projeto_flutter/pages/location_map_page.dart';
import 'package:projeto_flutter/services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class LocationSearch extends StatefulWidget {
  final Function(GeoPoint) onLocationSelected;
  final GeoPoint? initialLocation;

  const LocationSearch({
    Key? key,
    required this.onLocationSelected,
    this.initialLocation,
  }) : super(key: key);

  @override
  State<LocationSearch> createState() => _LocationSearchState();
}

class _LocationSearchState extends State<LocationSearch> {
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _searchResults = [];
  Timer? _debounce;
  bool _isLoading = false;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      setState(() {
        _hasPermission = permission != LocationPermission.denied && 
                         permission != LocationPermission.deniedForever;
      });
    } catch (e) {
      setState(() {
        _hasPermission = false;
      });
    }
  }

  Future<void> _requestLocationPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      setState(() {
        _hasPermission = permission != LocationPermission.denied && 
                         permission != LocationPermission.deniedForever;
      });
    } catch (e) {
      setState(() {
        _hasPermission = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!_hasPermission) {
      await _requestLocationPermission();
      if (!_hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissão de localização não concedida'),
          ),
        );
        return;
      }
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final location = GeoPoint(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      widget.onLocationSelected(location);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao obter localização: $e'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _locationService.searchAddress(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro na busca: $e'),
        ),
      );
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchLocation(query);
    });
  }

  void _selectLocation(Map<String, dynamic> location) {
    final geoPoint = GeoPoint(
      latitude: location['latitude'],
      longitude: location['longitude'],
    );
    widget.onLocationSelected(geoPoint);
    _searchController.clear();
    setState(() {
      _searchResults = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Buscar localização',
            hintText: 'Digite um endereço para buscar',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchResults = [];
                      });
                    },
                  )
                : null,
            border: const OutlineInputBorder(),
          ),
          onChanged: _onSearchChanged,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _hasPermission || _isLoading ? _getCurrentLocation : _requestLocationPermission,
                icon: const Icon(Icons.my_location),
                label: Text(_hasPermission ? 'Usar minha localização' : 'Permitir acesso à localização'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LocationMapPage(
                        title: 'Selecionar Localização',
                        initialLocation: widget.initialLocation,
                        selectable: true,
                        onLocationSelected: widget.onLocationSelected,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.map),
                label: const Text('Selecionar no mapa'),
              ),
            ),
          ],
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: LinearProgressIndicator(),
          ),
        if (_searchResults.isNotEmpty)
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(top: 8),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  return ListTile(
                    title: Text(
                      result['name'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${result['latitude']}, ${result['longitude']}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    onTap: () => _selectLocation(result),
                    leading: const Icon(Icons.location_on),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
