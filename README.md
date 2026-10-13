
# Microsoft Azure Cloud Deployment (Linux VM and SQL Database)

An individual project in which I deployed and configured a Linux virtual machine and an Azure SQL Database on Microsoft Azure, then used Azure CLI, Cloud Shell and PowerShell and Bash scripting to configure and manage the resources.

<img width="1179" height="534" alt="Picture1" src="https://github.com/user-attachments/assets/0881bad4-559e-4242-bb87-4a2353fbab46" />

## At a glance

| | |
|---|---|
| **Type** | Individual project |
| **Cloud platform** | Microsoft Azure (Azure for Students subscription) |
| **Compute** | Linux virtual machine, Debian 11, Standard B2s (2 vCPUs, 4 GiB memory), UK South |
| **Database** | Azure SQL Database on an Azure SQL server, UK South |
| **Tools** | Azure Portal, Azure CLI, Cloud Shell, PowerShell, Bash |
| **Skills** | Cloud infrastructure setup, VM provisioning, SQL database deployment, firewall rules, authentication, scripted resource management, resource groups |

## What I built

- **A Linux virtual machine.** A Debian 11 VM named `MyLinuxVM` in the UK South region, sized Standard B2s, with its own virtual network, public IP address and network interface, all inside a resource group.
- **An Azure SQL Database.** A SQL database and its SQL server, created in a separate resource group.
- **Network and access settings.** Firewall rules and authentication configured on the resources.
- **Pricing tier.** Chose a tier for the database and a size for the VM with cost in mind.


## How it was done

1. Created resource groups to hold the related resources.
2. Provisioned the Linux VM, including its network, public IP and size.
3. Created the SQL server and database, then set the firewall rules and authentication.
4. Connected to the VM and verified it was running.
5. Used Cloud Shell with PowerShell and Azure CLI to check and manage the resources by command instead of through the portal. For example, `Get-AzVM` confirmed the VM's name, location and provisioning state as `Succeeded`.
6. Wrote Bash and PowerShell scripts to automate parts of the configuration (see the Scripts section below).



## Screenshots

**Cloud Shell confirming the VM's state**

<img width="1126" height="169" alt="image" src="https://github.com/user-attachments/assets/798818ba-80ef-49b2-9c84-3644a8762ed6" />

**The resources in the Azure portal**

<img width="1634" height="517" alt="image" src="https://github.com/user-attachments/assets/5480c492-e331-40d6-a4e7-1c84c8cfa55a" />

## Scripts

The `scripts/` folder holds scripts that set up and manage the same deployment from the command line. They were rewritten as clean, reusable versions after the project, because I did not keep the original scripts from the time. They follow the same setup (a Debian 11 VM in UK South and a SQL database) but are not the exact files I ran then.

| Script | Language | What it does |
|---|---|---|
| `scripts/create-vm.sh` | Bash, Azure CLI | Creates a resource group, a network security group that allows SSH only from one IP address, and a Debian 11 VM that uses SSH key login |
| `scripts/create-sql.ps1` | PowerShell, Az module | Creates a SQL server and database, and opens the server firewall to one IP address only. It asks for the admin password when it runs, so no password is stored in the file |
| `scripts/check-resources.ps1` | PowerShell, Az module | Read-only report on the VM, its power state, the SQL server, firewall rules and databases |
| `scripts/cleanup.sh` | Bash, Azure CLI | Deletes the resource groups after you type DELETE to confirm |

Run the first two in Cloud Shell, or in any terminal after signing in with `az login` or `Connect-AzAccount`:

```
ALLOWED_SSH_CIDR="203.0.113.4/32" ./scripts/create-vm.sh
./scripts/create-sql.ps1 -AllowedClientIp "203.0.113.4"
```

Replace the example address with your own public IP address. Settings such as the VM size, region and tier are variables at the top of each script. Check that the Debian 11 image is still offered with `az vm image list --publisher Debian --offer debian-11 --all --output table`, since older images are retired over time. If it is not, change the `IMAGE` value to a current Debian release.

## Cost and clean-up

The project ran on an Azure for Students subscription. VMs and databases keep costing money while they exist, so resources should be stopped or deleted when finished. Deleting a resource group removes everything inside it:

```
az group delete --name <resource-group-name>
```

## What I practised

- Choosing sizes, regions and pricing tiers for compute and database resources
- Securing access with firewall rules and authentication
- Managing infrastructure from the command line instead of only the portal
- Organising resources with resource groups
- Working with Linux in a cloud environment

## Limitations

This is a small learning deployment on a student subscription, not a production setup. It has no load balancing, monitoring, backups or automated deployment pipeline.

## Related

- GitHub: https://github.com/keeganchinyenze
- LinkedIn: https://www.linkedin.com/in/keeganchinyenze
