# Service Registry

Provides a registry of each of the services running on their own isolate and reference to
the ports which are required send messages to that service. Intended to remove the
burden from the developer of managing Isolates, exchanging ports and keeping services
alive.

## Usage
Simply as service you need from the registry and hooking into the channels.

```dart
  /// Registry is a Singleton.
  ServiceRegistry registry = new ServiceRegistry()

  /// Would return the echo service. Use any list operaters you like...
  registry.availableServices.singleWhere((s) => (s.Type == 'Echo Service'));
```

## Provision
One of the main services provided, the registry takes care of all the exchanging
of port and the configuration of the underlying Isolate. All that is required is
the path to the service entry point and the package path of where the source is
located for the service.

## Termination
By passing in the registration for a particular service the can terminate a the by orderly shutdown of the service, the associated ports and channels.

## Manage
The registery uses it best effort to manage and services this it registers. Should the service become unavailable

## Scoped
The registry is intended to be scope limited and can not be used to pass a
dependency beyond it's immediate scope. Services like dependencies should only
point in one direction.

* Code Chunk A running in Isolate A, creates service Z, X & Y.
* Code Chunk B running in Isolate A, creates service W.

* Both code Chunks A & B will be able to see services Z, W, X & Y.

* Should service X create service D, service D will appear only in the service
registry for service X.

* Service D may not even have a serviceRegistry, it only knowns about service
X via the ports it has reference to.

Put another way there is no updating or syncronising across all the different
memory spaces that maybe available concurrently across the application.
