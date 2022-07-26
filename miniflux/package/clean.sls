# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as miniflux with context %}

include:
  - {{ sls_config_clean }}

Miniflux is absent:
  compose.removed:
    - name: {{ miniflux.lookup.paths.compose }}
    - volumes: {{ miniflux.install.remove_all_data_for_sure }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if miniflux.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ miniflux.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if miniflux.install.rootless %}
    - user: {{ miniflux.lookup.user.name }}
{%- endif %}
    - require:
      - sls: {{ sls_config_clean }}

Miniflux compose file is absent:
  file.absent:
    - name: {{ miniflux.lookup.paths.compose }}
    - require:
      - Miniflux is absent

Miniflux user session is not initialized at boot:
  compose.lingering_managed:
    - name: {{ miniflux.lookup.user.name }}
    - enable: false
    - onlyif:
      - fun: user.info
        name: {{ miniflux.lookup.user.name }}

Miniflux user account is absent:
  user.absent:
    - name: {{ miniflux.lookup.user.name }}
    - purge: {{ miniflux.install.remove_all_data_for_sure }}
    - require:
      - Miniflux is absent
    - retry:
        attempts: 5
        interval: 2

{%- if miniflux.install.remove_all_data_for_sure %}

Miniflux paths are absent:
  file.absent:
    - names:
      - {{ miniflux.lookup.paths.base }}
    - require:
      - Miniflux is absent
{%- endif %}
