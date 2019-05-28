# Deployment with Ansible

### Running Ad-Hoc Commands

```sh
ansible master -m ping --private-key=~/.ssh/rocket
```

### Using Ansible Vault

#### Encrypting

```sh
ansible-vault encrypt roles/deploy/files/env-dev
```

#### Decrypting

```sh
ansible-vault decrypt roles/deploy/files/env-dev
```

#### Viewing

```sh
ansible-vault view roles/deploy/files/env-dev
```

#### Editing

```sh
ansible-vault edit roles/deploy/files/env-dev
```

### Importing Test Data on Development Server

```sh
ansible-playbook -i development playbooks/import_local_data.yml --private-key=~/.ssh/rocket --vault-password-file=vault_pass.txt
``` 
#### Single Encrypted Variable

*Example* password: password123
```sh
ansible-vault encrypt_string password123 --vault-password-file=vault_pass.txt
```

Copy result and paste in group_vars/all

Verify via debug:
```
- debug:
    msg: "password is: {{ password }}"
```
