# Find and update each profile's .bashrc file with common aliases and new prompt
# Also update /etc/skel/.bashrc so all new users will have these settings

# Only run if this is an Ubuntu node and salt version is 3XXX.X to avoid issues with file.blockreplace
{% if (grains['os'] == 'Ubuntu') and (grains['saltversion'].startswith('3')) %}
  # Create list of all .bashrc files for all existing users
  {% set filelist = salt['file.find']('/home',type='f',name='.bashrc') %}
  # Add /etc/skel/.bashrc to filelist so all new accounts will have these settings
  {% set skel = ['/etc/skel/.bashrc'] %}
  {% set filelist = filelist + skel %}
  {% for file in filelist %}
    ps1_block_{{ loop.index }}:
      file.blockreplace:
        - name: {{ file }}
        - marker_start: "# This section is managed by Salt -START-"
        - marker_end: "# This section is managed by Salt -END-"
        # Check regional Pillar to see if this is preprod. Preprod gets cyan prompt, prod gets red.
        {% if salt['pillar.get']('regional:region.id') == 'dc6' %}
        - content: |
            
            # Common aliases
            alias ll='ls -alF'
            alias untar='tar -zxvf'
            alias gti='git'
            
            # Set the prompt
            export PS1="${debian_chroot:+($debian_chroot)}\[\033[01;36m\]\u@\h:[\[\033[00m\]\w\[\033[01;36m\]]\n\t \$\[\033[00m\] "  
        {% else %}      
        - content: |
            
            # Common aliases
            alias ll='ls -alF'
            alias untar='tar -zxvf'
            alias gti='git'
            
            # Set the prompt
            export PS1="${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@\h:[\[\033[00m\]\w\[\033[01;31m\]]\n\t \$\[\033[00m\] "
        {% endif %}
        - append_if_not_found: True
        - backup: '.bak'
        - show_changes: True
        - append_newline: True
  {% endfor %}
{% endif %}