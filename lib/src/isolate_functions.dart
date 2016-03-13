library isolateFunctions;

import 'dart:async';
import 'dart:isolate';

/// Returns a list will the provision port, service port and Isolate.
Future<List> spawnIsolate(Uri serviceEntry, Uri rootPack) async {
  var servicePort = new ReceivePort();
  var provisionPort = new ReceivePort();
  var startupArgs = [provisionPort.sendPort, servicePort.sendPort];
  var startupCode = 9999;
  return Isolate
      .spawnUri(serviceEntry, startupArgs, startupCode, packageRoot: rootPack)
      .then((Isolate iso) {
    List provisioned = [provisionPort, servicePort, iso];
    return provisioned;
  });
}

/// Listens on provision port for the service details.
Future<Map> identifyService(ReceivePort provisionPort) {
  var completer = new Completer();
  identficationComplete(Map identity) {
    provisionPort.close();
    completer.complete(identity);
  }
  provisionPort.listen((Map serviceIdentity) {
    assert(serviceIdentity.length == 8);
    identficationComplete(serviceIdentity);
  });
  return completer.future;
}

/// Test to see if the Isolate is Alive by pinging it.
Future<bool> isIsolateAlive(Isolate iso) {
  Duration timeLimit = new Duration(milliseconds: 10);
  Completer completer = new Completer();
  ReceivePort pingResponsePort = new ReceivePort();

  fail() => completer.complete(false);
  success() => completer.complete(true);
  timeout() => false;

  int expResponse =
      (new DateTime.now().millisecondsSinceEpoch / iso.hashCode).round();

  pingResponsePort.listen((response) {
    pingResponsePort.close();
    (expResponse == response) ? success() : fail();
  });

  iso.ping(pingResponsePort.sendPort, response: expResponse, priority: 1);

  return completer.future.timeout(timeLimit, onTimeout: timeout);
}
