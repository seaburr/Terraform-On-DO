#!/usr/bin/python3

import os
import sys
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
    'digitalocean_ssh_key': ['name', 'fingerprint']
}

extra_vars = {
    'ansible_ssh_user': 'root',
    'web_mount_point': '/var/www',
    'web_sub_directory': 'html',
    'web_mount_point_type': 'nfs',
    'ansible_ssh_common_args': '-o StrictHostKeyChecking=no -o userknownhostsfile=/dev/null'
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
        os.chdir(f'{sys.path[0]}/infrastructure')
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
            public_ips = []
            private_ips = []
            inventory[tag] = {}
            for droplet in self.droplets:
                if tag in droplet['digitalocean_droplet_tags']:
                    hosts.append(droplet['digitalocean_droplet_ipv4_address'])
                    public_ips.append(droplet['digitalocean_droplet_ipv4_address'])
                    private_ips.append(droplet['digitalocean_droplet_ipv4_address_private'])
                inventory[tag]['hosts'] = hosts
                inventory[tag]['vars'] = self.vars
            ansible_tag = tag.replace('-', '_')
            inventory[tag]['vars'][f'{ansible_tag}_public_ips'] = public_ips
            inventory[tag]['vars'][f'{ansible_tag}_private_ips'] = private_ips
            if 'digitalocean_volume_name' in inventory[tag]['vars']:
                nfs_mount_point = str('/mnt/' + inventory[tag]['vars']['digitalocean_volume_name'].replace('-', '_'))
                inventory[tag]['vars']['nfs_mount_point'] = nfs_mount_point
        inventory['_meta'] = {}
        inventory['_meta']['hostvars'] = {}
        return inventory

    def get_inventory(self):
        return json.dumps(self.ansible_inventory, indent=2)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--save', '-s', help='Generates Ansible inventory and stores to disk as inventory.json.',
                        action='store_true')
    parser.add_argument('--list', action='store_true')
    args = parser.parse_args()
    do = DigitalOceanInventory()
    if args.list:
        print(do.get_inventory())
    elif args.save:
        with open('inventory.json', 'w') as inventory:
            inventory.write(do.get_inventory())


if __name__ == '__main__':
    main()
