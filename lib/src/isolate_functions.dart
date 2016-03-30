library isolateFunctions;

import 'dart:async';
import 'dart:isolate';
import 'dart:developer';

/// Returns a List with the Spawned Isolate, the temporary provisioning port and
/// a Requester Port. The sendPort part of above ports  where passed to the Isolate
/// during spawning.
///
/// The Spawned Isolate is in a paused state.
/// This function Errors out if Isolate can not provisioned.
Future<Map> spawnIsolate(Uri serviceEntry, List serviceArgs) async {
  final int startupCode = 9999;
  final ReceivePort serviceResponsePort = new ReceivePort();
  final ReceivePort onExitPort = new ReceivePort();
  final String exitSignature = 'EXIT:${onExitPort.hashCode}';
  final ReceivePort onErrorPort = new ReceivePort();
  final ReceivePort tempProvisioningPort = new ReceivePort();
  Isolate spawned;
  Map spawnedElements = new Map();
  List startupArgs = new List();

  Map provisioningMap = {
    'tempProPort': tempProvisioningPort.sendPort,
    'serviceResponsePort': serviceResponsePort.sendPort
  };

  serviceArgs.isNotEmpty
      ? startupArgs = [provisioningMap, serviceArgs]
      : startupArgs = [provisioningMap];

  try {
    spawned = await Isolate.spawnUri(serviceEntry, startupArgs, startupCode,
        paused: true, automaticPackageResolution: true);
    spawned.addOnExitListener(onExitPort.sendPort, response: exitSignature);
    spawned.addErrorListener(onErrorPort.sendPort);
    spawned.resume(spawned.pauseCapability);

    spawnedElements['isolate'] = spawned;
    spawnedElements['onErrorPort'] = onExitPort;
    spawnedElements['onExitPort'] = onExitPort;
    spawnedElements['onExitSignature'] = exitSignature;
    spawnedElements['serviceResponseOnPort'] = serviceResponsePort;
    spawnedElements['tempExchangePort'] = tempProvisioningPort;

  } on IsolateSpawnException catch (e) {
    throw new IsolateSpawnException(
        'Attempt to spawn Isolate ${serviceEntry.toString()} with ${startupArgs.toString()} and startup code ${startupCode}, Failed!');
    log('Fatel - Upable to spawn new Isolate! $e');
  }

  return spawnedElements;
}

/// Commences the remote connection by listen the service details
/// to be sent back from the remote service. If this does not happen
/// an acceptable time frame we complete with an error.
Future<Map> commenceRemoteConnection(Map spawnedIsolate) {
  final Duration timeLimit = new Duration(milliseconds: 10);
  var completer = new Completer();
  ReceivePort exchangePort = spawnedIsolate['tempExchangePort'];

  completeExchange(Map serviceDetails) {
    exchangePort.close();
    completer.complete(serviceDetails);
  }

  failedExchange() {
    exchangePort.close();
    completer.completeError(new RemoteError(
        'Timeout For Port Exchange Reached: ${spawnedIsolate.toString()}', ''));
  }

  exchangePort.listen((Map serviceDetails) {
    assert(serviceDetails.isNotEmpty);
    completeExchange(serviceDetails);
  });

  return completer.future.timeout(timeLimit, onTimeout: failedExchange);
}

/// Listens to the provision port passed during spawning for an service credential
/// map, which contains details of the service along with a serviceRequestPort(sendPort)
/// where the service wants it's request sent.
Future<Map> identifyService(ReceivePort provisionPort) {
  var completer = new Completer();
  identificationCompleted(Map identity) {
    provisionPort.close();
    completer.complete(identity);
  }
  provisionPort.listen((Map serviceIdentity) {
    assert(serviceIdentity.length == 9);
    identificationCompleted(serviceIdentity);
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
