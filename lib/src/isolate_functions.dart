library isolateFunctions;

import 'dart:async';
import 'dart:isolate';

/// Returns a list containing the Isolate, a provision receiving port and a request Port (SendPort)
/// of the just provisioned service.
///
/// The new Service is in a state where it needs to provide a serviceRequestPort and indentify itself during the
/// process. It useds the provisionPort.sendPort passed during spawning to achieve this.
/// The spawning payload already containts the sendPort where it should send it's respondes.
Future<List> spawnIsolate(Uri serviceEntry, Uri rootPack) async {
  var serviceResponsePort = new ReceivePort();
  var provisionPort = new ReceivePort();
  var startupArgs = [provisionPort.sendPort, serviceResponsePort.sendPort];
  var startupCode = 9999;
  return Isolate
      .spawnUri(serviceEntry, startupArgs, startupCode, packageRoot: rootPack)
      .then((Isolate iso) {
    List provisioned = [provisionPort, serviceResponsePort, iso];
    return provisioned;
  });
}

/// Listens to the provision port passed during spawning for an service credential
/// map, which contains details of the service along with a serviceRequestPort(sendPort)
/// where the service wants it's request sent.
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
