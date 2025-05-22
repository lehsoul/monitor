---
- name: Cleanup old log files and truncate Docker logs
  hosts: all
  become: yes

  tasks:

    - name: Find and delete system logs older than 14 days
      find:
        paths: /var/log/
        patterns: "*.log"
        age: 14d
        recurse: yes
      register: old_logs

    - name: Delete old log files
      file:
        path: "{{ item.path }}"
        state: absent
      loop: "{{ old_logs.files }}"

    - name: Find Docker container logs
      shell: "find /var/lib/docker/containers/ -name '*-json.log'"
      register: docker_logs

    - name: Truncate Docker logs safely
      copy:
        content: ""
        dest: "{{ item }}"
      loop: "{{ docker_logs.stdout_lines }}"

