library echoService;

import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

/// This service is used as a test service to determine if a new service can be
/// provision.
/// Once provisioned on it's own isolate, able to undertake a port exchange
/// protocol giving the provider a port upon which to send messages to this
/// service.
/// The service also provides a low level identification service that can echo
/// it's identity with a request code. The above happens on the private management
/// ports.

/// Main entry point for a service, Args and startup code is used to establish
/// any required shaking.
main(List startupArgs, int startupCode) {
  assert(startupArgs.isNotEmpty);
  assert(startupCode != null);
  final String serviceName = "EchoService";
  final String serviceVersion = '1';
  final ReceivePort serviceRequestPort = new ReceivePort();
  final ReceivePort tempProvisionReceivePort = new ReceivePort();
  SendPort outBoundMessagePort;
  SendPort reponsePort = startupArgs[1];
  final String serviceIdent = Isolate.current.hashCode.toString();

  /// Service Credentials return back to provisioner as proof of life.
  final Map<String, String> serviceCreds = {
    'ServiceName': serviceName,
    'ServiceVersion': serviceVersion,
    'ServiceId': serviceIdent,
    'ServiceEnvironment': Platform.operatingSystem,
    'ServiceVMVersion': Platform.version,
    'ServiceSourcePath': Platform.packageRoot,
    'ServiceStartScript': Platform.script.toString(),
    'ServiceRequestPort': serviceRequestPort.sendPort,
  };

  /// **Executes the Port Exchange Protocol.**
  ///
  /// When an Isolate is first the StartupArgs & StartupCode is the only way
  /// to pass parameters in. Depending on the code which the Isolate is to execute
  /// we may need to establish ports for the two way communication. That is
  /// purpose of this protocol, handshake.
  ///
  /// 1. The Provisioner request two way communication by passing '9999' in the
  /// startup code.
  ///
  /// 2. This Isolate check to see if the provisioner has passed us a port we
  /// can send to them on. This will be in the 'startupArgs'. If it is there
  /// one can assume the provisioner is holding the receive end of the port. They
  /// may or may not started to listen yet.
  ///
  /// 3. This Isolate creates that's it 'inBoundMessagePort' and creates a sendPort
  /// from it. Then by using the SendPort the provisioner has provided in startupArgs,
  /// a credential message is sent to the provisioner. Contained within that message
  /// is the SendPort created from the inBoundMessagePort. The Provider then thats
  /// that message as proof that the Isolate is running.
  ///
  /// 4. The provisioner registers this Isolate and the service it is running when
  /// it receives the credentials map. Upon registration the provisioner may do further
  /// configurations.
  exchangePorts(List startArgs, Map credentials) {
    SendPort provisionPortSendPort = startArgs[0];
    assert(provisionPortSendPort != null);
    provisionPortSendPort.send(credentials);
    log('Credentials & Ports Exchanged');
  }

  ////////////////////////////////
  /// ** Actual Echo Service **
  ///
  /// This service just echos back to the requester the payload they sent, with
  /// some overhead to identify the service.
  ///
  /// ServiceRequestPort is Listened to (Hence it can not be one used for exchange)
  /// ServiceResponsePort has response to consumer request sent on.
  echoService(Map serviceDetails, ReceivePort serviceRequest,
      SendPort serviceResponse) {
    String serviceName = serviceDetails['ServiceName'];
    String serviceVersion = serviceDetails['ServiceVersion'];
    String serviceId = serviceDetails['ServiceId'];

    serviceRequest.listen((Map request) {
      log('Message Received By Echo Service. $request');
      Map response = {
        'ServiceRequestReceived': new DateTime.now().microsecondsSinceEpoch,
        'ServiceRequestTrxNum': request.containsKey('requestId')
            ? request['requestId']
            : 'No Trx Number Supplied.',
        'ServiceName': serviceName,
        'ServiceVersion': serviceVersion,
        'ServiceId': serviceId,
        'ServiceResponse': request.containsKey('payload')
            ? request['payload']
            : 'Payload of this request was empty',
        'ServiceResponseDispatched': new DateTime.now().microsecondsSinceEpoch
      };
      log("Echo Service Response: $response");
      serviceResponse.send(response);
    });
  }

  // Has the provisioner requested to send futher messages from this service.
  bool isPortExchangeRequested() => startupCode == 9999 ? true : false;

  // Has the provisioner provided the service with a port to send message on.
  bool isPortExchangePossible() => startupArgs[0] != null ? true : false;

  // Open the doors for business by handing over the credentials and the
  // inBoundMessage Port, which has yet to be listened too.
  setupService(Map creds, ReceivePort requestPort) {
    log('Service Setup');
    echoService(creds, serviceRequestPort, startupArgs[1]);
  }

  /// Informs the provisioner that a port exchange is not possible.
  sendProvisionFail() {
    throw new RemoteError(
        "Port Exchange Not Possible! SendPort not found in startupArgs",
        "No Stack");
  }

  if (isPortExchangeRequested() && isPortExchangePossible()) {
    exchangePorts(startupArgs, serviceCreds);
    setupService(serviceCreds, serviceRequestPort);
  } else {
    sendProvisionFail();
  }
}
