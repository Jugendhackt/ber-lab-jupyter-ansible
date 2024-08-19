import yaml, json, argparse, os
from jupyter_server.auth.security import passwd
from pwgen import pwgen

# Function to create hosts entries
def create_hosts_info(n, config):
    hosts_infos = []

    # Generate host entries
    for i in range(1, n+1):
        # Placeholder for password and hashed password generation
        pw = pwgen(10, symbols=False, capitalize=False)
        hashed_pw = passwd(pw)
        hosts_infos_entry = {
            'subdomain': f'{i:03d}.{config["hostname"]}',
            'pass': pw,
            'hashed_pass': hashed_pw,
        }
        hosts_infos.append(hosts_infos_entry)
    
    return hosts_infos



def main():
    parser = argparse.ArgumentParser(description="Hostname generation with password and hashed passwords.")
    parser.add_argument("-n","--num", type=int, required=True, help="The number of hosts to generate")
    args = parser.parse_args()
    with open('config.yaml', 'r') as file:
        config = yaml.safe_load(file)
        
    host_infos = create_hosts_info(args.num, config)
    # Write to YAML file for ansible
    with open('ansible/config.yaml', 'w') as file:
        ansible_cfg = {
            'main_domain': config["domain"],
            'notebooks': host_infos,
            'admins': config["admins"],
            }
        yaml.dump(ansible_cfg, file, indent=2, default_style="'", default_flow_style=False, sort_keys=False)

    # Write to json file for terraform
    with open('terraform/config.tfvars.json','w') as file:
        tf_config = {
            'domain': config["domain"],
            'hcloud_token': config["hcloud_token"], 
            'name': config["hostname"],
            'ssh_key_location': config["ssh_key_location"]
            }
        json.dump(tf_config, file, indent=2, sort_keys=False)

    with open('ansible/hosts','w') as file:
        private_key_file = os.path.splitext(config["ssh_key_location"])[0]
        ansible_hosts_data = {
            'servers': {
                'hosts': {
                    f'{config["hostname"]}.{config["domain"]}': {'ansible_user': 'alpaca', 'ansible_ssh_private_key_file': private_key_file}
                }
            }
        }
        yaml.dump(ansible_hosts_data, file, indent=2, sort_keys=False, )


if __name__ == "__main__":
    main()
# Call the function to create the files
