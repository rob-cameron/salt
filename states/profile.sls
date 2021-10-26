# Modify the contents of /etc/skel/.bashrc with a text block Salt can manage.
# Ultimately updates the prompt structure and color based on environment


# Replace content of a text block in /etc/skel/.bashrc, delimited by line markers
# Text block sets the value of PS1 based on the 'role' grain
# If text block does not exist, it will append it to the end of the file
{% if grains['os'] == 'Ubuntu' %}
ps1_block:
  file.blockreplace:
    - name: /etc/skel/.bashrc
    - marker_start: "# This section is managed by Salt -START-"
    - marker_end: "# This section is managed by Salt -END-"
    {% if grains['role'] == 'preprod' %}
    - content: 'export PS1="${debian_chroot:+($debian_chroot)}\[\033[01;36m\]\u@\h:[\[\033[00m\]\w\[\033[01;36m\]]\n\t \$\[\033[00m\] "'
    {% elif grains['role'] == 'Prod' %}
    - content: 'export PS1="${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@\h:[\[\033[00m\]\w\[\033[01;31m\]]\n\t \$\[\033[00m\] "'
    {% endif %}
    - append_if_not_found: True
    - backup: '.bak'
    - show_changes: True

# /etc/skel/.bashrc will be copied to ~/.bashrc for any new user, however any updates also need to be pushed to existing users
# This will find all .bashrc files in /home recursively and update from /etc/skel/.bashrc should they differ
copy_skel_bashrc_to_existing:
  cmd.run:
    - name: for i in $(find /home -type f -name .bashrc); do rsync -c /etc/skel/.bashrc $i; done
{% endif %}