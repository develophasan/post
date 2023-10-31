import 'dart:async';
import 'dart:isolate';

void backgroundTask(SendPort sendPort) {
  Timer.periodic(Duration(seconds: 5), (Timer t) {
    sendPort.send('Arkaplanda çalışıyor: ${DateTime.now()}');
  });
}

void main(List<String> args, SendPort sendPort) {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);

  receivePort.listen((data) {
    if (data == 'start') {
      backgroundTask(sendPort);
    }
  });
}
