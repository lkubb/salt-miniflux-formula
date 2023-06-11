# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_package_install = tplroot ~ ".package.install" %}
{%- from tplroot ~ "/map.jinja" import mapdata as miniflux with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}

Miniflux environment files are managed:
  file.managed:
    - names:
      - {{ miniflux.lookup.paths.config_miniflux }}:
        - source: {{ files_switch(
                        ["miniflux.env", "miniflux.env.j2"],
                        config=miniflux,
                        lookup="miniflux environment file is managed",
                        indent_width=10,
                     )
                  }}
      - {{ miniflux.lookup.paths.config_postgres }}:
        - source: {{ files_switch(
                        ["postgres.env", "postgres.env.j2"],
                        config=miniflux,
                        lookup="postgres environment file is managed",
                        indent_width=10,
                     )
                  }}
    - mode: '0640'
    - user: root
    - group: {{ miniflux.lookup.user.name }}
    - makedirs: true
    - template: jinja
    - require:
      - user: {{ miniflux.lookup.user.name }}
    - watch_in:
      - Miniflux is installed
    - context:
        miniflux: {{ miniflux | json }}
