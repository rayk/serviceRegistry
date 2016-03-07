library api.types;

import 'package:serviceRegistry/src/serviceRegistration.dart';

/// Singleton Service Registry for the current isolate.
class ServiceRegistry {
  static final ServiceRegistry _instance = new ServiceRegistry._internal();
  List<ServiceRegistration> _currentServices = new List();

  /// Returns a list of a service registrations for all the currently
  /// available services.
  List<ServiceRegistration> get availableServices => _currentServices;

  /// Returns the current instance of the ServiceRegistry with the latest
  /// currently available services.
  factory ServiceRegistry() => _instance;

  ServiceRegistry._internal();
}
