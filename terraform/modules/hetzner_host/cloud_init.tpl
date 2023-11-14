#cloud-config
package_update: true

packages:
  - python3

users:
  - name: alpaca
    ssh-authorized-keys:
      - ${ssh_key}
    sudo: ALL=(ALL) NOPASSWD:ALL
