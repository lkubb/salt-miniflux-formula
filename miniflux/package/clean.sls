# vim: ft=sls

{#-
    Removes the miniflux, postgres containers
    and the corresponding user account and service units.
    Has a depency on `miniflux.config.clean`_.
    If ``remove_all_data_for_sure`` was set, also removes all data.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_clean = tplroot ~ ".config.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as miniflux with context %}

include:
  - {{ sls_config_clean }}

{%- if miniflux.install.autoupdate_service %}

Podman autoupdate service is disabled for Miniflux:
{%-   if miniflux.install.rootless %}
  compose.systemd_service_disabled:
    - user: {{ miniflux.lookup.user.name }}
{%-   else %}
  service.disabled:
{%-   endif %}
    - name: podman-auto-update.timer
{%- endif %}

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

{%- if miniflux.install.podman_api %}

Miniflux podman API is unavailable:
  compose.systemd_service_dead:
    - name: podman.socket
    - user: {{ miniflux.lookup.user.name }}
    - onlyif:
      - fun: user.info
        name: {{ miniflux.lookup.user.name }}

Miniflux podman API is disabled:
  compose.systemd_service_disabled:
    - name: podman.socket
    - user: {{ miniflux.lookup.user.name }}
    - onlyif:
      - fun: user.info
        name: {{ miniflux.lookup.user.name }}
{%- endif %}

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
