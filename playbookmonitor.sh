---
- name: Check software vulnerabilities
  hosts: local
  tasks:

    - name: Check Java version
      shell: java -version 2>&1 | head -n 1
      register: java_version
      ignore_errors: yes

    - name: Check if Java is vulnerable
      debug:
        msg: "Java VULNERABLE: {{ java_version.stdout }}"
      when: '"1.8.0_121" in java_version.stdout or "openjdk version \"1.8.0_121"' in java_version.stdout'

    - name: Check Python version
      shell: python3 --version 2>&1
      register: python_version
      ignore_errors: yes

    - name: Check if Python is vulnerable
      debug:
        msg: "Python VULNERABLE: {{ python_version.stdout }}"
      when: '"3.6" in python_version.stdout or "3.5" in python_version.stdout'

    - name: Check MongoDB version
      shell: mongod --version 2>&1 | grep "db version"
      register: mongo_version
      ignore_errors: yes

    - name: Check if MongoDB is vulnerable
      debug:
        msg: "MongoDB VULNERABLE: {{ mongo_version.stdout }}"
      when: '"db version v3.6" in mongo_version.stdout or "db version v4.0" in mongo_version.stdout'

