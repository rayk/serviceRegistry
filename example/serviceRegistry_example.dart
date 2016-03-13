/// This code example can be executed from the CLI and demonstrates the provisioning
/// of the default echo service. Sending it a message and the message being returned.

library serviceRegistry.example;

import 'dart:async';
import 'dart:developer';

import 'package:serviceRegistry/serviceRegistry.dart';

main() async {
  var echoServicePath = ['lib', 'src', 'echo_service', 'entry_point.dart'];
  var packagePath = ['lib', 'src', 'echo_service'];

  var serviceReg = await startService(echoServicePath, packagePath);
  print('Your ${serviceReg.type} has been provisioned!');
  Stream inbound = serviceReg.receiveChannel;
  StreamSink outbound = serviceReg.sendChannel;

  Map request = {'requestId': "209358", 'payload': 'Hello it is me'};

  inbound.listen((Map msg) {
    log('Message Received;');
  });

  outbound.add(request);
  log('Message Sent');
}
