library isolateFunctions;

import 'dart:async';
import 'dart:isolate';

Future<List> spawnIsolate(Uri serviceEntry, Uri rootPack) async {
  var servicePort = new ReceivePort();
  var provisionPort = new ReceivePort();
  var startupArgs = [provisionPort.sendPort, servicePort.sendPort];
  var startupCode = 9999;
  Isolate
      .spawnUri(serviceEntry, startupArgs, startupCode, packageRoot: rootPack)
      .then((Isolate iso) {
    List provisioned = [provisionPort, servicePort, iso];
    return provisioned;
  });
}

Future<Map> identifyService(ReceivePort provisionPort) async {
  provisionPort.listen((Map serviceIdentity) {
    assert(serviceIdentity.length == 8);
    provisionPort.close();
    return serviceIdentity;
  });
}
