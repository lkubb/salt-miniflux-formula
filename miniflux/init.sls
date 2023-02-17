# vim: ft=sls

{#-
    *Meta-state*.

    This installs the miniflux, postgres containers,
    manages their configuration and starts their services.
#}

include:
  - .package
  - .config
  - .service
