# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as miniflux with context %}

miniflux service is dead:
  compose.dead:
    - name: {{ miniflux.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if miniflux.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ miniflux.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if miniflux.install.rootless %}
    - user: {{ miniflux.lookup.user.name }}
{%- endif %}

miniflux service is disabled:
  compose.disabled:
    - name: {{ miniflux.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if miniflux.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ miniflux.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if miniflux.install.rootless %}
    - user: {{ miniflux.lookup.user.name }}
{%- endif %}
