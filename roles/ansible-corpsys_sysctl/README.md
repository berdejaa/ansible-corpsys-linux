## Ansible Role: ansible-corpsys-system-settings
The purpose of this role is:

- Configure the following sysctl properties:
  - vm.swappiness 
  - vm.zone_reclaim_mode
  - net.ipv4.tcp_keepalive_time
- Configure system ulimit settings

## Requirements
This role doesn't have any requirements

## Installation
To install this role you have these options:

1. Clone or download this repo into your playbook roles folder
2. Add the following code to your requirements.yml:

```
# Install ansible-corpsys-system-settings Module
- name: ansible-corpsys-system-settings
  src: git+https://github.com/bodybuildingcom/ansible-corpsys-system-settings.git
  version: 0.1.1
```
NOTE: Please update the above code to use the latest (correct) version.
