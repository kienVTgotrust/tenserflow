import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';
import 'package:tflite_flutter_plus/tflite_flutter_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({Key? key, required this.camera}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Detection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CameraApp(camera: camera),
    );
  }
}

class CameraApp extends StatefulWidget {
  final CameraDescription camera;

  const CameraApp({Key? key, required this.camera}) : super(key: key);

  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late Interpreter _interpreter;
  late List<Rect> _detectedFaces;

  @override
  void initState() {
    super.initState();
    _detectedFaces = [];
   
    initData();
  }

  Future<void>initData()async{
await  _initializeCamera();
await _loadModel();
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _controller.initialize();
    await _initializeControllerFuture;

    if (mounted) {
      setState(() {
        // Start image stream when camera is initialized
        _controller.startImageStream((CameraImage image) {
          _detectFaces(image);
        });
      });
    }
    setState(() {}); // Force update after initialization
  }

  Future<void> _loadModel() async {
    try {
  
   


     _interpreter =
        await Interpreter.fromAsset("iris_landmark.tflite");





    } catch (e) {
      print('Failed to load model: $e');
    }
  }

  void _detectFaces(CameraImage image) async {
    if (_interpreter == null) return;

    // Prepare input tensor
    final input = _preprocessCameraImage(image);
    final inputShape = _interpreter.getInputTensor(0).shape;
    final inputType = _interpreter.getInputTensor(0).type;
    final inputBuffer = TensorBuffer.createFixedSize(inputShape, inputType);
    inputBuffer.loadList(input, shape: []);

    // Prepare output tensor
    final outputShape = _interpreter.getOutputTensor(0).shape;
    final outputType = _interpreter.getOutputTensor(0).type;
    final outputBuffer = TensorBuffer.createFixedSize(outputShape, outputType);

    // Run inference
    _interpreter.run(inputBuffer.buffer, outputBuffer.buffer);

    // Process output
    final faces = _postprocessOutput(outputBuffer);
    setState(() {
      _detectedFaces = faces;
    });
  }

  List<int> _preprocessCameraImage(CameraImage image) {
    // Preprocess CameraImage into a list of pixels (adjust according to your model)
    // This is a basic example, you need to customize this based on your model requirements
    return List<int>.filled(1, 0); // Replace with actual image processing logic
  }

  List<Rect> _postprocessOutput(TensorBuffer outputBuffer) {
    // Process output tensor to get face rectangles
    // This is a basic example, adjust according to your model output format
    return [Rect.fromLTWH(100, 100, 50, 50)]; // Replace with actual postprocessing logic
  }

  @override
  void dispose() {
    _controller.dispose();
    _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Face Detection')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller),
                CustomPaint(
                  painter: FacePainter(faces: _detectedFaces),
                  size: Size.infinite,
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class FacePainter extends CustomPainter {
  final List<Rect> faces;

  FacePainter({required this.faces});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (var face in faces) {
      canvas.drawRect(face, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
