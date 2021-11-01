# Find and update each profile's .bashrc file with common aliases and new prompt
# Also update /etc/skel/.bashrc so all new users will have these settings

{% if grains['os'] == 'Ubuntu' %}

  {% set filelist = salt['file.find']('/home',type='f',name='.bashrc') %}
  {% set skel = ['/etc/skel/.bashrc'] %}
  {% set filelist = filelist + skel %}
  {% for file in filelist %}
    ps1_block_{{ loop.index }}:
      file.blockreplace:
        - name: {{ file }}
        - marker_start: "# This section is managed by Salt -START-"
        - marker_end: "# This section is managed by Salt -END-"
        - content: |
            
            # Common aliases
            alias ll='ls -alF'
            alias untar='tar -zxvf'
            alias gti='git'
            
            # Set the prompt
            export PS1="${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@\h:[\[\033[00m\]\w\[\033[01;31m\]]\n\t \$\[\033[00m\] "
        - append_if_not_found: True
        - backup: '.bak'
        - show_changes: True
        - append_newline: True
  {% endfor %}
{% endif %}