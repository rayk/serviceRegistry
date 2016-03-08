library api.types;

import 'dart:isolate';

/// Singleton Service Registry for all current services.
///
/// Contains List of all the currently available services in the form
/// of [ServiceRegistrations].
class ServiceRegistry {
  static final ServiceRegistry _instance = new ServiceRegistry._internal();
  static List<ServiceRegistration> _currentServices = new List();

  /// Returns a list of al currently available services.
  /// available services.
  List<ServiceRegistration> get availableServices => _currentServices;

  /// Returns the current instance of the ServiceRegistry with the latest
  /// currently available services.
  factory ServiceRegistry() => _instance;

  ServiceRegistry._internal();

  static _addService(ServiceRegistration rego) {
    _currentServices.add(rego);
  }
}

/// Repersents a currently available service.
class ServiceRegistration {
  String _serviceType;
  int _serviceVersion;

  /// Returns the specific type of the service that indicates what the
  /// service provides it's consumer.
  String get type => _serviceType;

  /// Returns the version number of this service.
  int get version => _serviceVersion;

  /// Creates and registers a new service.
  ServiceRegistration(Isolate iso) {}
}
