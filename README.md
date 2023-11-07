# Ansible playbook for deploying a Commercio Network node
The playbook configures a server to be a Commercio Network full node and installs a script that detects whether the node is losing blocks.
If the node loses blocks, a message will be forwarded to a slack channel of your choice.

 * **The playbook is designed for mainnet or testnet installation. It should not be used for other types of installations**

## Prerequisites
The prerequisites to use this playbook are:
* Have a server on which to install the node
* Have python3 installed (version >= 3.5)
     * To check the version:
         ```bash
         python3 -V
         ```
* Have ansible installed (version >= core 2.9)
     * To check the version:
         ```bash
         ansible --version
         ```
* Have `gantsign.golang` installed for ansible
     * To install it:
         ```bash
         ansible-galaxy install gantsign.golang
         ```

## Usage
To use the playbook you need to proceed as follows:

1. Create and add the `hosts.ini` file to the root directory of this repo. [Example hosts file](.hosts.ini). Parameters:
     * `ansible_host`: IP of the machine
     * `moniker`: name of the node
     * `external_drive`: optional parameter to specify if the node database is to be installed on an external disk. Use this parameter to specify the path to that disk
     * `comm_user`: name of the user that will be created and used by the node service
     * `sync_type`: This parameter decides how database synchronization occurs.
     You can have 5 values:
         * `pull`: synchronization occurs by doing an `rsync` from the new node to the node from which it synchronizes.
         * `push`: synchronization occurs by doing an `rsync` from the node from which you synchronize to the new node.
         * `dump`: synchronization occurs by dumping the dump to disk and unpacking it.
         * `statesync`: synchronization occurs via statesync.
         * `none`: synchronization occurs normally.
    
     You can change the behavior of the playbook based on the variables indicated in the `all` file located in the `main/group_vars` path. Below is the table of their meaning:
     | Variable name | Usage |
     | -- | -- |
     | `bin_version` | Version of the Commercionetworkd binary to use |
     | `chain_id` | Blockchain chain-id |
     | `genesis` | Genesis file URL |
     | `comm_repo` | Path and name of where the Commercio.network binary repository is downloaded |
     | `home_folder` | Home where the `.commercionetwork` folder is installed |
     | `go_path` | Path of installed go |
     | `cosmovisor_version` | Version of Cosmovisor to install |
     | `sync_node` | Node IP to sync from in case of `sync_type` = `push` or `pull` |
     | `sync_node_home_folder` | Node home folder to sync from in case of `sync_type` = `push` or `pull` |
     | `trust_rpc1` | First RPC to sync from in case of `sync_type` = `statesync` |
     | `trust_rpc2` | Second RPC to sync from in case of `sync_type` = `statesync` |
     | `slack_hook` | Webhook where to send reports about a node losing blocks. **No script will be installed if a webhook isn't set** |

    The `chain_id` variable determines the blockchain chain-id to be used for the installation. Depending on whether you want to install the Commercionetwork in the mainnet or testnet , you can configure the `chain_id` variable accordingly.

    By specifying the `chain_id` variable and ensuring that you align it with the associated settings, such as the first and second RPC to sync in case of `sync_type = statesync`, you can adapt the installation process to suit your targeted network

2. Proceed to run the `main` playbook:
```bash
ansible-playbook -i .hosts.ini main/commercio.yml
```

Run the playbook from the root folder of this repo.

### Manual installation of the script
If you don't choose to install the script via the playbook you can install it manually, here's how:
1. Copy the script from `main/post_install/tasks/test_height.sh` on the server
2. Replace the `{{ slack_hook }}` variable in the file with your own slack webhook
3. Add the script to a crontab using the `crontab -e` command. We suggest running the script every 5 minutes

## Troubleshooting
There may be errors when launching the playbook. These are the most common:

1. During the `install_binary : Run 'make' on target` step there may be a possible failure in compiling the binary due to the `TestProcessTestSuite` test not passing.
The playbook will ignore the error and continue execution. The binary still compiles and will work fine.

2. During the `setup_configuration : Download genesis file` step, a possible failure in the genesis download may occur. This error is caused by Github not responding to the request correctly. In this case the playbook will stop. This error rarely occurs and it will be enough to restart the playbook to complete the configuration.
