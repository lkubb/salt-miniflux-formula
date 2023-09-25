# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_file = tplroot ~ ".config.file" %}
{%- from tplroot ~ "/map.jinja" import mapdata as miniflux with context %}

include:
  - {{ sls_config_file }}

Miniflux service is enabled:
  compose.enabled:
    - name: {{ miniflux.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if miniflux.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ miniflux.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
    - require:
      - Miniflux is installed
{%- if miniflux.install.rootless %}
    - user: {{ miniflux.lookup.user.name }}
{%- endif %}

Miniflux service is running:
  compose.running:
    - name: {{ miniflux.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if miniflux.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ miniflux.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if miniflux.install.rootless %}
    - user: {{ miniflux.lookup.user.name }}
{%- endif %}
    - watch:
      - Miniflux is installed
      - sls: {{ sls_config_file }}
