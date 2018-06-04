{% from "linux/dbserver/mysql-server.map.jinja" import mysql with context %}

Installation package MySQL:
  pkg.installed:
    - names: {{ mysql.pkgs }}
      
{#
{% for pkg in mysql.pkgs %}
      - {{ pkg }}
{% endfor %}
#}

{% set repls = [
    { 'port': mysql.port },
    { 'datadir': mysql.data },
    { 'socket': mysql.data + "/mysql.sock" }
  ] %}

{% for repl in repls %}
{% for key,value in repl.items() %}
Configuration service MySQL ({{ key }}):
  file.replace:
    - name: {{ mysql.cfg }}
    - pattern: ^port[ ]*=.*
    - repl: port = {{ mysql.port }}
    - append_if_not_found: True
    - not_found_content: port = {{ key }} = {{ value }}
    - require:
      - pkg: Installation package MySQL
{% endfor %}
{% endfor %}

Suppression base de test MySQL:
  mysql_database.absent:
    - name: test
    - require:
        - service: {{ mysql.svc }}
