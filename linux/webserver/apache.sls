{% from "linux/webserver/apache.map.jinja" import apache with context %}
Demarrage du service Apache:
  service.running:
    - name: {{ apache.svc }}
    - enable: True
    - watch:
      - pkg: {{ apache.pkg }}
      - file: {{ apache.cfg }}

Installation Apache sur Linux:
  pkg.installed:
    - name: {{ apache.pkg }}

Configuration Apache:
  file.managed:
    - template: jinja
    - name: {{ apache.cfg }}
    - source: {{ apache.cfg_tpl }}
    - require:
      - pkg: {{ apache.pkg }}

{% if 'php' in grains["roles"] %}
Installation PHP:
  pkg.installed:
    - names:
        - {{ apache.php_pkg }}
{% if 'php-mysql' in grains["roles"] %}
        - {{ apache.php_dep_mysql }}
{% endif %}
    - watch_in:
        - service: {{ apache.svc }}      
{% endif %}
{% if 'RedHat' in grains['os_family'] %}
Ouverture Port 80:
  firewalld.present:
    - name: public
    - ports:
      - {{ apache.port }}/tcp
    - prune_services: False
    - require:
      - pkg: {{ apache.pkg }}
{% endif %}
