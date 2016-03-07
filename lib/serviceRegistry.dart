/// # Service Registry Library
///
/// Maintains a Registry of currently available services provisioned from
/// the isolate the registry is executing on. This is achieved by providing
/// functions that provision and terminate services.
///
/// Provisioning entails ensuring the code for the specified service has it
/// own execution loop and heap space. Once provisioned the registry is updated
/// to contain the objects required to use the service.
///
/// The Registry is a Singleton hence it is not possible to a reference to a
/// service which is not current.
///
/// Failure to provision is treated as Error, you can expect a complete crash.
/// Termination failures on the other handle are treated as exceptions which
/// can addressed with a another call to terminate.
///
/// Terminate needs to be called to free resources associated with service.
library serviceRegistry;

export 'src/api.dart';
