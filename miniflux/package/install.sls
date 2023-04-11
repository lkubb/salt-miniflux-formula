# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as miniflux with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

Miniflux user account is present:
  user.present:
{%- for param, val in miniflux.lookup.user.items() %}
{%-   if val is not none and param != "groups" %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
    - usergroup: true
    - createhome: true
    - groups: {{ miniflux.lookup.user.groups | json }}
    # (on Debian 11) subuid/subgid are only added automatically for non-system users
    - system: false

Miniflux user session is initialized at boot:
  compose.lingering_managed:
    - name: {{ miniflux.lookup.user.name }}
    - enable: {{ miniflux.install.rootless }}
    - require:
      - user: {{ miniflux.lookup.user.name }}

Miniflux paths are present:
  file.directory:
    - names:
      - {{ miniflux.lookup.paths.base }}
    - user: {{ miniflux.lookup.user.name }}
    - group: {{ miniflux.lookup.user.name }}
    - makedirs: true
    - require:
      - user: {{ miniflux.lookup.user.name }}

{%- if miniflux.install.podman_api %}

Miniflux podman API is enabled:
  compose.systemd_service_enabled:
    - name: podman.socket
    - user: {{ miniflux.lookup.user.name }}
    - require:
      - Miniflux user session is initialized at boot

Miniflux podman API is available:
  compose.systemd_service_running:
    - name: podman.socket
    - user: {{ miniflux.lookup.user.name }}
    - require:
      - Miniflux user session is initialized at boot
{%- endif %}

Miniflux compose file is managed:
  file.managed:
    - name: {{ miniflux.lookup.paths.compose }}
    - source: {{ files_switch(["docker-compose.yml", "docker-compose.yml.j2"],
                              lookup="Miniflux compose file is present"
                 )
              }}
    - mode: '0644'
    - user: root
    - group: {{ miniflux.lookup.rootgroup }}
    - makedirs: True
    - template: jinja
    - makedirs: true
    - context:
        miniflux: {{ miniflux | json }}

Miniflux is installed:
  compose.installed:
    - name: {{ miniflux.lookup.paths.compose }}
{%- for param, val in miniflux.lookup.compose.items() %}
{%-   if val is not none and param != "service" %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
{%- for param, val in miniflux.lookup.compose.service.items() %}
{%-   if val is not none %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
    - watch:
      - file: {{ miniflux.lookup.paths.compose }}
{%- if miniflux.install.rootless %}
    - user: {{ miniflux.lookup.user.name }}
    - require:
      - user: {{ miniflux.lookup.user.name }}
{%- endif %}

{%- if miniflux.install.autoupdate_service is not none %}

Podman autoupdate service is managed for Miniflux:
{%-   if miniflux.install.rootless %}
  compose.systemd_service_{{ "enabled" if miniflux.install.autoupdate_service else "disabled" }}:
    - user: {{ miniflux.lookup.user.name }}
{%-   else %}
  service.{{ "enabled" if miniflux.install.autoupdate_service else "disabled" }}:
{%-   endif %}
    - name: podman-auto-update.timer
{%- endif %}
