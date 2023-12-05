ansible-corpsys_sudo
=========

Configures sudoers

Requirements
------------

None

Role Variables
--------------

{{ package_state }}: present, absent, etc.
{{ full_sudo }}: a list of user names or @groupnames.

Dependencies
------------

None

Example Playbook
----------------

    - hosts: servers
      roles:
         - { role: bbcom_sudo }

License
-------

Copyright bodybuilding.com

Author Information
------------------

Alberto Sierra <alberto.sierra@bodybuilding.com>
