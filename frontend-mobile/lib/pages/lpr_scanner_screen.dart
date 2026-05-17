import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const _lprApiUrl = 'http://10.0.2.2:8000/detect-plate';

class LprScannerScreen extends StatefulWidget {
  const LprScannerScreen({super.key});

  @override
  State<LprScannerScreen> createState() => _LprScannerScreenState();
}

class _LprScannerScreenState extends State<LprScannerScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _camCtrl;
  bool _camReady = false;
  bool _scanning = false;
  bool _detected = false;
  String? _detectedPlate;

  late AnimationController _laserCtrl;
  late Animation<double> _laserAnim;

  @override
  void initState() {
    super.initState();
    _laserCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _laserAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _laserCtrl, curve: Curves.easeInOut),
    );
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    _camCtrl = CameraController(cameras.first, ResolutionPreset.high);
    await _camCtrl!.initialize();
    if (mounted) setState(() => _camReady = true);
  }

  Future<void> _startScan() async {
    setState(() {
      _scanning = true;
      _detected = false;
      _detectedPlate = null;
    });

    try {
      final xfile = await _camCtrl!.takePicture();
      final bytes = await xfile.readAsBytes();

      final request = http.MultipartRequest('POST', Uri.parse(_lprApiUrl));
      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: 'plate.jpg'));

      final streamed = await request.send().timeout(const Duration(seconds: 15));
      final body = json.decode(await streamed.stream.bytesToString());

      if (!mounted) return;

      if (body['success'] == true && body['plate'] != null) {
        setState(() {
          _scanning = false;
          _detected = true;
          _detectedPlate = body['plate'] as String;
        });
      } else {
        setState(() => _scanning = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(body['message'] ?? 'No plate detected — try again')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _scanning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _camCtrl?.dispose();
    _laserCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan License Plate', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: !_camReady
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE8845C)))
          : Stack(
              children: [
                // camera preview
                Positioned.fill(child: CameraPreview(_camCtrl!)),

                // dark overlay
                Positioned.fill(
                  child: CustomPaint(painter: _OverlayPainter()),
                ),

                // scanning frame + laser
                Center(
                  child: SizedBox(
                    width: 280,
                    height: 140,
                    child: Stack(
                      children: [
                        // frame corners
                        CustomPaint(
                          size: const Size(280, 140),
                          painter: _FramePainter(detected: _detected),
                        ),
                        // laser line
                        if (_scanning)
                          AnimatedBuilder(
                            animation: _laserAnim,
                            builder: (_, __) => Positioned(
                              top: _laserAnim.value * 130,
                              left: 8,
                              right: 8,
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                    Colors.transparent,
                                    const Color(0xFFE8845C),
                                    Colors.transparent,
                                  ]),
                                  boxShadow: [BoxShadow(color: const Color(0xFFE8845C).withOpacity(0.6), blurRadius: 6)],
                                ),
                              ),
                            ),
                          ),
                        // detected plate result
                        if (_detected && _detectedPlate != null)
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF4CAF50), width: 2.5),
                              ),
                              child: Text(
                                _detectedPlate!,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 4,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // status label
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.38,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      _detected
                          ? 'Plate Detected!'
                          : _scanning
                              ? 'Scanning...'
                              : 'Align plate inside the frame',
                      style: TextStyle(
                        color: _detected ? const Color(0xFF4CAF50) : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // bottom buttons
                Positioned(
                  bottom: 40,
                  left: 24,
                  right: 24,
                  child: _detected
                      ? Column(
                          children: [
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => Navigator.pop(context, _detectedPlate),
                              child: const Text('Use This Plate', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: _startScan,
                              child: const Text('Scan Again', style: TextStyle(color: Colors.white70)),
                            ),
                          ],
                        )
                      : FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: _scanning ? Colors.grey : const Color(0xFFE8845C),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _scanning ? null : _startScan,
                          child: Text(
                            _scanning ? 'Scanning...' : 'Scan Now',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

// Dark overlay with a transparent cutout in the center
class _OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.6);
    final cutW = 280.0, cutH = 140.0;
    final cx = (size.width - cutW) / 2;
    final cy = (size.height - cutH) / 2;
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx, cy, cutW, cutH), const Radius.circular(8)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// Corner brackets frame
class _FramePainter extends CustomPainter {
  final bool detected;
  const _FramePainter({required this.detected});

  @override
  void paint(Canvas canvas, Size size) {
    final color = detected ? const Color(0xFF4CAF50) : const Color(0xFFE8845C);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const len = 24.0;
    final w = size.width, h = size.height;
    // top-left
    canvas.drawLine(Offset(0, len), Offset(0, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(len, 0), paint);
    // top-right
    canvas.drawLine(Offset(w - len, 0), Offset(w, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, len), paint);
    // bottom-left
    canvas.drawLine(Offset(0, h - len), Offset(0, h), paint);
    canvas.drawLine(Offset(0, h), Offset(len, h), paint);
    // bottom-right
    canvas.drawLine(Offset(w - len, h), Offset(w, h), paint);
    canvas.drawLine(Offset(w, h), Offset(w, h - len), paint);
  }

  @override
  bool shouldRepaint(_FramePainter old) => old.detected != detected;
}
