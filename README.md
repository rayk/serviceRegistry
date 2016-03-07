# Service Registry

Provides a registry of each of the services running on their own isolate and reference to
the ports which are required to deal with them.

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
