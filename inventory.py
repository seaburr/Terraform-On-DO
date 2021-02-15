'''
This script generates a dynamic Ansible inventory file from DigitalOcean Terraform state files. There is a dict
that define which values to collect out of resources for variables for host groups. Theres a second dict that defines
any extra variables that need to be added to each host group. Default behavior is to print out the inventory as Ansible
expects. There's an optional flag of --save/-s that will generate save the inventory file to inventory.json
'''

import subprocess
import argparse
import json

relevant_tf_state_values = {
    'digitalocean_droplet': ['name', 'ipv4_address', 'ipv4_address_private', 'tags'],
    'digitalocean_database_cluster': ['name', 'host', 'private_host', 'port'],
    'digitalocean_database_user': ['name', 'password'],
    'digitalocean_database': ['name'],
    'digitalocean_domain': ['id'],
    'digitalocean_volume': ['name', 'size', 'initial_filesystem_type'],
    'digitalocean_certificate': ['domains'],
    'digitalocean_ssh_key': ['name', 'fingerprint']
}


extra_vars = {
    'ansible_ssh_user': 'root'
}


class DigitalOceanInventory(object):

    def __init__(self):
        self.tags = []
        self.droplets = []
        self.vars = {}
        self.inventory_json = json.loads(self._get_terraform_output())
        self._generate_groups()
        self._generate_vars()
        self.ansible_inventory = self._generate_ansible_inventory()
    
    def _get_terraform_output(self):
        process = subprocess.Popen(['terraform', 'show', '-json'],
                                   stdout=subprocess.PIPE,
                                   stderr=subprocess.PIPE,
                                   universal_newlines=True)
        stdout, stderr = process.communicate()
        return stdout

    def _parse_resource(self, resource, resource_type, relevant_objects):
        data = {}
        for key, value in resource['values'].items():
            if key in relevant_objects:
                data[f'{resource_type}_{key}'] = value
        return data

    def _generate_groups(self):
        tags = 'digitalocean_tag'
        droplets = 'digitalocean_droplet'
        for resource in self.inventory_json['values']['root_module']['resources']:
            if resource['type'] == tags:
                self.tags.append(resource['values']['name'])
            elif resource['type'] == droplets:
                self.droplets.append(self._parse_resource(resource, droplets, relevant_tf_state_values[droplets]))

    def _generate_vars(self):
        for resource in self.inventory_json['values']['root_module']['resources']:
            if resource['type'] in relevant_tf_state_values.keys() and resource['type'] not in \
                    ['digitalocean_tags', 'digitalocean_droplets']:
                for key, value in resource['values'].items():
                    if key in relevant_tf_state_values[resource['type']] and key not in ['ip', 'tags']:
                        resource_id = resource['type']
                        self.vars[f'{resource_id}_{key}'] = value
                for key, value in extra_vars.items():
                    self.vars[key] = value

    def _generate_ansible_inventory(self):
        inventory = {}
        for tag in self.tags:
            hosts = []
            inventory[tag] = {}
            for droplet in self.droplets:
                if tag in droplet['digitalocean_droplet_tags']:
                    hosts.append(droplet['digitalocean_droplet_ipv4_address'])
                inventory[tag]['hosts'] = hosts
                inventory[tag]['vars'] = self.vars
        return inventory

    def get_inventory(self):
        return json.dumps(self.ansible_inventory, indent=2)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--save', '-s', help='Generates Ansible inventory and stores to disk as inventory.json.',
                        action='store_true')
    args = parser.parse_args()
    do = DigitalOceanInventory()
    if not args.save:
        print(do.get_inventory())
    else:
        with open('inventory.json', 'w') as inventory:
            inventory.write(do.get_inventory())


if __name__ == '__main__':
    main()