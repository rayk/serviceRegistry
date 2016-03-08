import 'package:path/path.dart' as path;
import 'package:serviceRegistry/serviceRegistry.dart';

/// API Test of get hold of the under registry different conditions.
@TestOn('vm')
import 'package:test/test.dart';

void main() {
  /// Just get a single authoritative registry.
  group('Aquire Service Registry.', () {
    test('Should return a service registry without any entries.', () {
      ServiceRegistry registry = serviceRegister();
      expect(registry, isNotNull);
      expect(registry.availableServices.isEmpty, isTrue);
    });

    test('Should not create a new registry when nothing has changed.', () {
      ServiceRegistry registryA = serviceRegister();
      ServiceRegistry registryB = serviceRegister();
      expect(registryA == registryB, isTrue);
    });
  });

  /// Adding a service and it should appear in the registry.
  group('Register a new service:', () {
    test('Should return a Registry after service is registered.', () async {
      var context = new path.Context();
      Uri servicePath = new Uri.file(context.join(
          context.current, "test", 'testEchoService', 'echoService.dart'));
      provisionService(servicePath).then((ServiceRegistry svry) {
        expect(svry, isNotNull);
      });
    });

    test('Should have a entry in the Registry for the new service .', () {});

    test('Should the type and version number as declared by the service..',
        () {});

    test('Should error out when handed a broken or non existent URI.', () {});

    test('Should be able to register multiple instances of the same service.',
        () {});

    test('Should discriminate instances of the same service and version.',
        () {});
  });

  /// Lookup a service by providing the enum for the service type.
  group('Query for a service:', () {
    test('Should  .', () {});
  });

  group("Service ready for use:", () {
    test('Should return a channel to communicate with service.  .', () {});

    test('Should return a service description via the channel.', () {});
  });
  group("Unregister a service:", () {
    test('Should return a Registry after a service is unregister.', () {});

    test('Should throw expection when unregistering non-existing service.',
        () {});
  });
}
