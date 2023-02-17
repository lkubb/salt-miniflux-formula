# vim: ft=sls

{#-
    Starts the miniflux, postgres container services
    and enables them at boot time.
    Has a dependency on `miniflux.config`_.
#}

include:
  - .running
