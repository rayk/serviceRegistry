# Service Registry

Provides a registry of each of the services running on their own isolate and reference to
the ports which are required send messages to that service. Intended to remove the
burden from the developer of managing Isolates, exchanging ports and keeping services
alive.

## Usage
Simply as service you need from the registry and hooking into the channels.

```dart
  /// This is where we will assign our echo service
  ServiceRegistration srv;

  /// Registry itself is a Singleton.
  ServiceRegistry registry = new ServiceRegistry()

  /// Returns a signle echo service.
  srv = registry.services.singleWhere((s) => (s.Type == 'Echo Service'));

  /// We can now Listen to events from the service.
  srv.receiveChannel((event message){
    // Do what ever we like with the events.
    })
```

## Provision
One of the main services provided, the registry takes care of all the exchanging
of port and the configuration of the underlying Isolate. All that is required is
the path to the service entry point and the package path of where the source is
located for the service.
``` dart
/// I just provide a list of strings to get to my entry point, the slashes
/// are handled in the case of differnet operating systems. A path to packages
/// can also be given so entry points in different packages can be used.

ServiceRegistration myNewService;

List entryPoint = ['lib', 'src', 'echo_service', 'entry_point.dart'];
List package = ['lib', 'src', 'echo_service'];

myNewService = await startService(entryPoint, package);

```
This will provision the service asynchronously, return a ServiceRegistration when
it is completed. In the backgroud it ensures the ServiceRegistry is consistent. Ensuring
a services does not appear until it has been provisioned and is known to be running.

## Termination
By passing in the registration for a particular service the can terminate a the by orderly shutdown of the service, the associated ports and channels.
``` dart
/// Hand over the ServiceRegistration and rest is taken care of.

stopService(myNewService)

```
This allow and existing messages to be processed and then gracefully kill off the service and free the resources
which it was consuming.

## Manage
The registery uses it best effort to manage and services this it registers. Should the service become unavailable.
It does this by listening to every exist message and deciding if that services shutdown not by programatic instruction
it we provisions the service. There is nothing to be down here. The ServiceRegistration will disappear from the registery
then later reappear.

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
