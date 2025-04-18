import 'package:flutter/material.dart';

class CustomWaveform extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Center(
        child: Container(
          width: 300,
          height: 60,
          child: CustomPaint(
            painter: WaveformPainter(progress: 0.7),
          ),
        ),
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final double progress;

  WaveformPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final paintProgress = Paint()
      ..color = Colors.pinkAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw waveform
    final waveHeight = size.height / 2;
    final waveWidth = size.width / 30; // Adjust wave density
    for (double i = 0; i < size.width; i += waveWidth) {
      final x = i;
      final height = (waveHeight / 2) +
          (waveHeight / 2) * (0.5 + 0.5 * (1 - (i % waveWidth) / waveWidth));
      final yStart = (size.height - height) / 2;
      final yEnd = yStart + height;

      if (i / size.width <= progress) {
        canvas.drawLine(Offset(x, yStart), Offset(x, yEnd), paintProgress);
      } else {
        canvas.drawLine(Offset(x, yStart), Offset(x, yEnd), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

void main() {
  runApp(MaterialApp(home: CustomWaveform()));
}
