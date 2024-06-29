import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:realtime_face_recognition/ML/Recognition.dart';
class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(this.absoluteImageSize, this.recognitions, this.camDirec);

  final Size absoluteImageSize;
  final List<Recognition> recognitions;
  final CameraLensDirection camDirec;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.indigoAccent;

    for (Recognition recognition in recognitions) {
      final rect = Rect.fromLTRB(
        camDirec == CameraLensDirection.front
            ? (absoluteImageSize.width - recognition.location.right) * scaleX
            : recognition.location.left * scaleX,
        recognition.location.top * scaleY,
        camDirec == CameraLensDirection.front
            ? (absoluteImageSize.width - recognition.location.left) * scaleX
            : recognition.location.right * scaleX,
        recognition.location.bottom * scaleY,
      );

      canvas.drawRect(rect, paint);

      TextSpan span = TextSpan(
          style: const TextStyle(color: Colors.white, fontSize: 20),
          text: "${recognition.name}  ${recognition.distance.toStringAsFixed(2)}");
      TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(rect.left, rect.top));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
