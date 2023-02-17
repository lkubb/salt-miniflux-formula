Available states
----------------

The following states are found in this formula:

.. contents::
   :local:


``miniflux``
^^^^^^^^^^^^
*Meta-state*.

This installs the miniflux, postgres containers,
manages their configuration and starts their services.


``miniflux.package``
^^^^^^^^^^^^^^^^^^^^
Installs the miniflux, postgres containers only.
This includes creating systemd service units.


``miniflux.config``
^^^^^^^^^^^^^^^^^^^
Manages the configuration of the miniflux, postgres containers.
Has a dependency on `miniflux.package`_.


``miniflux.service``
^^^^^^^^^^^^^^^^^^^^
Starts the miniflux, postgres container services
and enables them at boot time.
Has a dependency on `miniflux.config`_.


``miniflux.clean``
^^^^^^^^^^^^^^^^^^
*Meta-state*.

Undoes everything performed in the ``miniflux`` meta-state
in reverse order, i.e. stops the miniflux, postgres services,
removes their configuration and then removes their containers.


``miniflux.package.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^
Removes the miniflux, postgres containers
and the corresponding user account and service units.
Has a depency on `miniflux.config.clean`_.
If ``remove_all_data_for_sure`` was set, also removes all data.


``miniflux.config.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^
Removes the configuration of the miniflux, postgres containers
and has a dependency on `miniflux.service.clean`_.

This does not lead to the containers/services being rebuilt
and thus differs from the usual behavior.


``miniflux.service.clean``
^^^^^^^^^^^^^^^^^^^^^^^^^^
Stops the miniflux, postgres container services
and disables them at boot time.


