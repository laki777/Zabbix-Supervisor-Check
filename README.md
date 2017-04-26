# Description
Supervisor daemon and apps monitoring through Zabbix.

Template "Template App Supervisor" finds all supervisor apps, creates new items and triggers.

# Dependencies
perl, sudo, zabbix-agent, zabbix-sender.

libswitch-perl library.

Installation
============
1. copy supervisor_check.pl to /etc/zabbix/
2. copy zabbix_agentd.d/supervisor.conf to /etc/zabbix/zabbix_agentd.d/
3. copy sudoers.d/zabbix (or its content) to /etc/sudoers.d/
4. chown root:root /etc/sudoers.d/zabbix ; chmod 440 /etc/sudoers.d/zabbix
5. chmod 755 /etc/zabbix/supervisor_check.pl
6. restart zabbix-agent daemon.
7. import "zbx_templates/Template App Supervisor check.xml" into your templates.
8. apply template "Template App Supervisor" host.

You need to setup the same Host name on Zabbix and client. 
