{# manage ip route for 2016 minions  #}

{% set debug = salt['pillar.get']('routes:debug', False) %}

{% set client_id = salt['grains.get']('id').split('.') | first %}
{% set backup_dir = salt['pillar.get']('routes:backup_dir', '/root/backup/ip_route') %}
{% set current_ip_route = salt['cmd.run']('ip route show').replace('\n',';').split(';') %}
{% set append_routes = salt['pillar.get']('routes:append', False) %}
{% set absent_routes = salt['pillar.get']('routes:absent', False) %}
{% set backup_counter = [] %}

{# ----------  add routes ----------- #}
{% if append_routes %}
{% for route_append_name in append_routes %}
{# set append route net and gw #}
{%- set target_net = salt['pillar.get']('routes:append:'~route_append_name~':net', False) -%}
{%- set target_gw  = salt['pillar.get']('routes:append:'~route_append_name~':gw', False) -%}

{# set counter to test current routes #}
{%- set match_counter = [] -%}

{# check if append route alredy exist #}
{% for route_line in current_ip_route -%}
  {%- if target_net in route_line -%}
    {%- if target_gw in route_line -%}
      {% if match_counter.append('match_found') %}{% endif %}
    {%- endif -%}
  {%- endif -%}
{%- endfor -%}

{# if check positive #}
{% if 'match_found' in match_counter %}
{# Match! not add append route #}
{% else %}
{# Not match add append route #}

{# do backup if make changes #}
{% if backup_counter.append('do_backup') %}{% endif %}

add_new_route_{{ route_append_name }}:
  cmd.run:
    - name: 'ip route replace {{ target_net }} via {{ target_gw }}'
    {% if debug %}
    - require_in:
      - cmd: show_current_routes
    {% endif %}
    - require:
      - cmd: do_backup
{% endif %}

{% endfor %}
{% endif %}
{# ---------------------------------------- #}

{# ----------- del routes ----------------- #}
{% if absent_routes %}
{% for route_absent_name in absent_routes %}
{# set absent route net  #}
{%- set target_net = salt['pillar.get']('routes:absent:'~route_absent_name~':net', False) -%}

{# set counter to test current routes #}
{%- set match_counter = [] -%}

{# check if append route alredy exist #}
{% for route_line in current_ip_route -%}
  {%- if target_net in route_line -%}
    {% if match_counter.append('match_found') %}{% endif %}
  {%- endif -%}
{%- endfor -%}

{# if check positive #}
{% if 'match_found' in match_counter %}
{# Match! remove route #}

{# do backup if make changes #}
{% if backup_counter.append('do_backup') %}{% endif %}

del_route_{{ route_absent_name }}:
  cmd.run:
    - name: 'ip route del {{ target_net }}'
    {% if debug %}    
    - require_in:
      - cmd: show_current_routes
    {% endif %}
    - require:
      - cmd: do_backup

{% else %}
{# Not match route exist #}
{# do nothing #}
{% endif %}
{% endfor %}
{% endif %}
{# ------------------------------------ #}


{% if 'do_backup' in backup_counter %}
make_backup_dir:
  file.directory:
    - name: {{ backup_dir }}
    - makedirs: True

do_backup:
  cmd.run:
    - name: 'ip route save > {{ backup_dir }}/ip_route_backup_$(date +%Y-%m-%d\_%H-%M-%S)'
    - require:
      - file: make_backup_dir
{% endif %}


{% if debug %}
show_current_routes:
  cmd.run:
    - name: 'ip route show'
{% endif %}


