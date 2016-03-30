library exampleEcho;

import 'dart:isolate';
import 'dart:developer';

import 'package:serviceRegistry/serviceRegistry.dart';

/// This is an example of how to implement a remote service, which will be started.
/// On it's own isolate and have it's own channels. Both of which the service itself
/// does not have to manage.
/// This entry_point is where the service is started. The primary purpose of
/// this service is to echo back to the request any message that it receives
/// On it's own isolate and have it's own channels. Both of which the service itself
/// does not have to manage.

/// Main that is kicked by startService.
main(List startupArguments, int startupCode) async {
  Map serviceDetails = {
    'serviceName': 'EchoService',
    'serviceVersion': '0.0.1',
    'startArgs': startupArguments,
    'startCode': startupCode
  };

  // Completes the connection back to the requester
  Map serviceRegistration = await completeRemoteConnection(serviceDetails);

  ReceivePort echoServiceRequest = serviceRegistration['inBoundReceivePort'];
  SendPort mainResponsePort = serviceRegistration['outBoundReplyPort'];

  // Main Echo Service
  List args = serviceRegistration['serviceArgs'];
  log('${args[0]}');
  echoServiceRequest.listen((Map request) {
    int messageReceived = new DateTime.now().microsecondsSinceEpoch;

    var requestId = request.containsKey('requestId')
        ? request['requestId']
        : "No Request Id Supplied";
    log('${args[1]} $requestId.');

    Map response = {
      'requestReceived': messageReceived,
      'requestHandled': serviceRegistration['name'],
      'handlerVersion': serviceRegistration['version'],
      'handlerId': serviceRegistration['Id'],
      'reponse':
          request.containsKey('payload') ? request['payload'] : "Empty Payload",
      'reponseSent': new DateTime.now().microsecondsSinceEpoch
    };

    request.containsKey('replyTo')
        ? request['replyTo'].send(response)
        : mainResponsePort.send(response);
    log("${args[2]} $requestId.");
  });
}
