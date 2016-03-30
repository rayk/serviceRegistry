import 'package:serviceRegistry/serviceRegistry.dart';
import 'dart:async';

/// API Test of get hold of the registry under different conditions and ensure
/// Is is consistent.
@TestOn('vm')
import 'package:test/test.dart';

void main() {
  /// Just get a single authoritative registry.
  group('Aquire Service Registry.', () {
    test('Should return a service registry without any entries.', () {
      ServiceRegistry registry = serviceRegister();
      expect(registry, isNotNull);
      expect(registry.services.isEmpty, isTrue);
    });

    test('Should not create a new registry when nothing has changed.', () {
      ServiceRegistry registryA = serviceRegister();
      ServiceRegistry registryB = serviceRegister();
      expect(registryA == registryB, isTrue);
    });

    test('Should contain no registrations in the registry', () {
      ServiceRegistry reg = new ServiceRegistry();
      expect(reg.services.isEmpty, isTrue);
    });
  });

  /// Register a Service and maintain consistency in the registry.
  group('Register a new service:', () {
    var entryPoint =
        new List.from(['lib', 'src', 'echo_service', 'entry_point.dart']);
    var package = new List.from(['lib', 'src', 'echo_service']);
    var serviceArgs = new List.from(['arg1', 'arg2', 'arg3', 'arg4']);

    test('Should start new service an update registry with registration.',
        () async {
      ServiceRegistry reg = new ServiceRegistry();
      startService(entryPoint, package, serviceArguments:serviceArgs).then((ServiceRegistration rego) {
        expect(rego.canAutoManage, isTrue, reason: 'Should be manageable');
        expect(rego.canMessage, isTrue, reason: 'should be able to send msgs');
        expect(rego.canPause, isTrue, reason: 'should have pause capabilities');
        expect(rego.canRespond, isTrue, reason: 'should have a receive port');
        expect(rego.canTerminate, isTrue, reason: 'should have termination');
        expect(rego.createdDateTime, equals(new isInstanceOf<DateTime>()));
        expect(rego.environment, isNotEmpty,
            reason: 'Should min data for this');
        expect(rego.id, isNotNull,
            reason: 'can be not implemented in some envs');
        expect(rego.receiveChannel, equals(new isInstanceOf<Stream>()));
        expect(rego.sendChannel, equals(new isInstanceOf<StreamSink>()));
        expect(rego.sourcePath, isNotNull, reason: 'Should know it package');
        expect(rego.startupScript, isNotNull, reason: 'needed for restart');
        expect(rego.type, isNotNull, reason: 'Should Know itself');
        expect(rego.version, isNotNull, reason: 'Should know its version');
        // Checks here to ensure that it is done on async block.
        expect(reg.services.length, equals(1),
            reason: 'No registry update after rego created.');
      });
      expect(reg.services.isEmpty, isTrue,
          reason: 'Registry updated before rego created.');
    });
  });

  /// Terminate a Service and maintain consistency in the registry.
  group("Service Termination:", () {
    var regtest = new ServiceRegistry();
    var entryPoint =
        new List.from(['lib', 'src', 'echo_service', 'entry_point.dart']);
    var package = new List.from(['lib', 'src', 'echo_service']);

    test('Should stop a service an update remove registration from registry.',
        () async {
      // The Add Service Test (Above) Could be running concurrently.
      String idOfOtherService;
      expect(regtest.services.length, lessThanOrEqualTo(1));

      ServiceRegistration regoExternalToThisTest;
      if (regtest.services.length == 1) {
        regoExternalToThisTest = regtest.services.first;
        assert(regoExternalToThisTest != null);
        idOfOtherService = regoExternalToThisTest.id;
        assert(idOfOtherService != null);
      }

      startService(entryPoint, package).then((ServiceRegistration testRego) {
        expect(testRego, isNotNull, reason: 'No service Rego returned.');
        expect(testRego.id, isNotNull);
        String idOfThisService = testRego.id;
        assert(idOfThisService != null);

        expect(idOfThisService == idOfOtherService, isFalse,
            reason: 'Two service with same Id we are screwed.');

        expect(regtest.services.contains((testRego)), isTrue,
            reason: 'This service has not been registered.');

        stopService(testRego);

        expect(regtest.services.contains((testRego)), isFalse,
            reason: 'This service has not been removed.');

        // If the external on managed to find it's way in.
        if (regoExternalToThisTest != null) {
          expect(regtest.services.contains((regoExternalToThisTest)), isTrue);
          stopService(regoExternalToThisTest);
          expect(regtest.services.isEmpty, isTrue);
        }
      });
    });
  });
}
