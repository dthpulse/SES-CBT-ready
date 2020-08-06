### Ansible playbooks to deploy SES7 on SUSE Greek hosts and prepare them for  benchmark with CBT

 - currently prepared for hosts:

   ```
   apollo.qa.suse.cz
   ares.qa.suse.cz
   artemis.qa.suse.cz
   hera.qa.suse.cz
   demeter.qa.suse.cz
   callisto.qa.suse.cz
   ```

- if you need to add or remove host:

  - edit _hosts_ file

  - edit *vars/bashrc.yml* appropriatly

- before you run playbooks:

  - put SCC server registration key into the file *vars/register.yml*

  - edit *vars/add_repos.yml*

- run playbooks:

  ```
  ANSIBLE_CONFIG=config/ansible.cfg ansible-playbook main.yml
  ```

- CBT is on apollo.qa.suse.cz:/opt 
  
  Run it like for example:

  ```
  ./cbt.py -a archive/SES7_M18_apollo_librbd -c /etc/ceph/ceph.conf apollo
  ```




