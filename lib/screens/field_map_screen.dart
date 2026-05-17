import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/field.dart';
import '../theme.dart';

class FieldMapScreen extends StatefulWidget {
  final PaddyField field;
  const FieldMapScreen({super.key, required this.field});
  @override
  State<FieldMapScreen> createState() => _FieldMapScreenState();
}

class _FieldMapScreenState extends State<FieldMapScreen> {
  final MapController _mapCtrl = MapController();
  LatLng? _myLocation;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) { setState(() => _permissionDenied = true); return; }
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      setState(() => _permissionDenied = true); return;
    }
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5),
    ).listen((pos) {
      if (mounted) setState(() => _myLocation = LatLng(pos.latitude, pos.longitude));
    });
  }

  void _goToMyLocation() {
    if (_myLocation != null) _mapCtrl.move(_myLocation!, 15);
  }

  @override
  Widget build(BuildContext context) {
    final fieldLatLng = widget.field.latitude != null && widget.field.longitude != null
        ? LatLng(widget.field.latitude!, widget.field.longitude!)
        : const LatLng(6.1184, 100.3685);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text('${widget.field.name} — Map',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _permissionDenied
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.location_off_rounded, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              const Text('Location permission required', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: Geolocator.openAppSettings,
                child: const Text('Open Settings'),
              ),
            ]))
          : FlutterMap(
              mapController: _mapCtrl,
              options: MapOptions(initialCenter: fieldLatLng, initialZoom: 14),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.demo_app',
                ),
                MarkerLayer(markers: [
                  // Field marker
                  Marker(
                    point: fieldLatLng,
                    width: 48,
                    height: 56,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        width: 36, height: 36,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.grass_rounded, color: Colors.white, size: 20),
                      ),
                      CustomPaint(
                        size: const Size(12, 8),
                        painter: _TrianglePainter(AppColors.primary),
                      ),
                    ]),
                  ),
                  // My location marker
                  if (_myLocation != null)
                    Marker(
                      point: _myLocation!,
                      width: 24, height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
                        ),
                      ),
                    ),
                ]),
              ],
            ),
      floatingActionButton: _permissionDenied ? null : FloatingActionButton.extended(
        onPressed: _goToMyLocation,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.my_location_rounded, color: Colors.white),
        label: const Text('My Location', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  const _TrianglePainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = ui.Path()
      ..moveTo(0, 0)..lineTo(size.width, 0)..lineTo(size.width / 2, size.height)..close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}
