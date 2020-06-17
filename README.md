# cortex-maas
Installation script for Metal as a Service

## Requirements

This requires a Ubuntu machine (bare-metal or VM) with Ubuntu server 18.04 (bionic) already installed.

The user should ensure all network interfaces are setup properly.

## Networking

At a minimum, the system MAAS is installed on should have one network interface on the subnet that MAAS should be responsible for.
On all network interfaces that MAAS will be responsible for, the server should be set to have a static IP.
This is because on those subnets MAAS will be setup as a DHCP server and it needs a static IP for itself for that subnet.

Additional network interfaces can exist to subnets MAAS does not control and on those interfaces the server can be setup to get its IP from a different DHCP server.

## Installation

Installation requires 'sudo' rights.

The script `install-maas.sh` requires 4 parameters.

* Hostname or IP for server:  This should be either and IP or a DNS entry that other systems can reference. IP is preferred in this particular case.
* Database password:  Password to use for the PostgreSQL database MAAS will use.
* Admin password:  Password to set for the `admin` user used to log into the MAAS web user interface.
* Admin email: Email to use for the admin user. Not really important but needs to be provided.

To run the script do:

```
  sudo ./install-maas.sh 192.168.7.10 dbpassw0rd adminpassw0rd admin@email.com
```

The script will ask to confirm installation.

## Finish configuration

Once the script is finished, open the url http://localhost:5240/MAAS/ into your browser and login with 'admin' and the password provided to the script.

For the "SSH keys for admin", select a source of "Upload" and paste in the SSH public key for the admin user.
This key will be injected into machines provisioned by MAAS that the admin user provisions.
Note that the username to use will depend on the OS installed. For example for Ubuntu you'll have to ssh using `ssh ubuntu@{machine-ip}` ensuring your account has the private key set up ok.

Once the SSH key is added, click "Go to dashboard".

Enter some value for "DNS forwarder". This can be an internal DNS or an external one like "1.1.1.1 1.0.0.1".
If you have a private Ubuntu archive like Artifactory, you can enter the URL next to "Ubuntu archive" field.

Select the images you would like to have available to deploy on machines and click "Update selection".
When done, click "Continue".

## Setup subnet to provision

To provide DHCP on the subnets of interest, click "Subnets" from the menu at top.
On the subnet you want to provide PXE booting and provisioning, click the "untagged" under "VLAN" of the subnet of choice.
Click "Enable DHCP".
Setup the start and end IP range to use.  Leave some IP range free for MAAS to allocate initially during commissioning.

## Confirm images synchronized

Click "Controllers" and ensure that the single rack controller shown indicates "Synced" under "Image status".

At this point, you should be ready to process machines that are PXE booting.

When first detected, machines will be inspected to retrieve their hardware specs and the machine will show up under `Machines` as `New`.

If you don't have any automated power control, select a new machine and edit it's power setting and select "Manual".

To provision a machine, you will need to select it from it's ready state and select "Commission".
When it switches to "Commissioning", press power on that bare-metal system (since the power control is manual).

Once commissioned, the state will change to "Ready".
To deploy an OS, select "Deploy" and pick the OS of choice.  If you only have a single image selected it will automatically pick that one.
When it shows "Deploying OS", press power button on that bare-metal system.

The OS will then be deployed.  You can then SSH into the box using the private SSH key that matches the public key uploaded earlier.

For more details on how to use MAAS, refer to the user manual: https://maas.io/docs

