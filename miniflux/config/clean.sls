# vim: ft=sls

{#-
    Removes the configuration of the miniflux, postgres containers
    and has a dependency on `miniflux.service.clean`_.

    This does not lead to the containers/services being rebuilt
    and thus differs from the usual behavior.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_service_clean = tplroot ~ ".service.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as miniflux with context %}

include:
  - {{ sls_service_clean }}

Miniflux environment files are absent:
  file.absent:
    - names:
      - {{ miniflux.lookup.paths.config_miniflux }}
      - {{ miniflux.lookup.paths.config_postgres }}
      - {{ miniflux.lookup.paths.base | path_join(".saltcache.yml") }}
    - require:
      - sls: {{ sls_service_clean }}
