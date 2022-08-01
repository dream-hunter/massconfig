# Massconfig

This is a simple tool for mass config management. Useful to spread config in a big company.

Before start you have to install FTP server, grant/restict access for some user.

!!!Do not use anonymous access to your configs!!!

1. Add devices IP to deviceslist file;
2. Start snmptracelist.sh script;
3. Start sortdevices.sh script;
4. Use snmpconfig.pl for cisco configuration;
5. Use sshconfig.pl for Juniper configuration.

Basicaly this project created for my own needs.