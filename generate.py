import yaml, toml, json, argparse
from jupyter_server.auth.security import passwd
from pwgen import pwgen

# Function to create hosts entries
def create_hosts_info(n):
    hosts_infos = []

    # Generate host entries
    for i in range(1, n+1):
        # Placeholder for password and hashed password generation
        pw = pwgen(10, symbols=False, capitalize=False)
        hashed_pw = passwd(pw)
        hosts_infos_entry = {
            'subdomain': f"{i:03d}",
            'pass': pw,
            'hashed_pass': hashed_pw,
        }
        hosts_infos.append(hosts_infos_entry)
    
    return hosts_infos



def main():
    parser = argparse.ArgumentParser(description="Hostname generation with password and hashed passwords.")
    parser.add_argument("-n","--num", type=int, required=True, help="The number of hosts to generate")
    args = parser.parse_args()
    host_infos = create_hosts_info(args.num)
    with open('config.yaml', 'r') as file:
        config = yaml.safe_load(file)
        
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
        subdomains = [entry["subdomain"] for entry in host_infos]
        tf_config = {
            'domain': config["domain"],
            'notebooks': subdomains, 
            'hcloud_token': config["hcloud_token"], 
            'hcloud_dns_token': config["hcloud_dns_token"],
            'name': config["hostname"]
            }
        json.dump(tf_config, file, indent=2, sort_keys=False)

    with open('ansible/hosts','w') as file:
        ansible_hosts_data = {
            'servers': {
                'hosts': {
                    f'{config["hostname"]}.{config["domain"]}': {'ansible_user': 'alpaca'}
                }
            }
        }
        yaml.dump(ansible_hosts_data, file, indent=2, sort_keys=False, )


if __name__ == "__main__":
    main()
# Call the function to create the files
