# CS 312 Course Project: Part 2

Clay Coffman
coffmacl@oregonstate.edu

## Automating the Minecraft server with Terraform and Ansible

### Background

Part 2 does the work of Part 1 with code instead of by hand in the AWS UI. The whole thing runs start to finish without ever opening the AWS console. Two tools split the work:

- **Terraform** provisions the AWS side: a security group, an SSH key pair, and one Ubuntu EC2 instance in the default VPC.
- **Ansible** connects to that instance over SSH and configures it: installs Docker, drops in a `docker-compose.yml` and a `systemd` unit, and starts the [`itzg/minecraft-server`](https://github.com/itzg/docker-minecraft-server) container.

I used the Docker image instead of installing Java on the host because it also fixes the shutdown problem from Part 1 (see [Shutting down properly](#shutting-down-properly) below).

### Requirements

You can run everything from your own machine (macOS or Linux; on Windows use WSL). Tools you need:


| Tool | Version | Why |
|------|---------|-----|
| Terraform | >= 1.10 | provisions AWS (1.10 has the native S3 state locking I use) |
| Ansible | >= 2.15 | configures the instance |
| AWS CLI | v2 | credentials, plus the reboot test |
| nmap | any | confirm the server is reachable |
| ssh-keygen | any | makes the deploy key (ships with OpenSSH) |


**AWS credentials.** This was built for the AWS Academy Learner Lab. Start the lab, click **AWS Details**, and paste the credentials block into `~/.aws/credentials`:

```
[default]
aws_access_key_id = ...
aws_secret_access_key = ...
aws_session_token = ...
```

Terraform reads those on its own. They expire when the lab session ends, so re-copy them each time you start the lab. Everything runs in `us-east-1`.

**One value to set.** Terraform state lives in an S3 bucket so a local run and the GitHub Actions pipeline share the same state. S3 bucket names are global, so if `cs312-mc-tfstate-yourname` is taken, change it in both `terraform/backend.tf` and `scripts/bootstrap-state.sh`. If you'd rather keep state on your machine and skip the pipeline, just delete `terraform/backend.tf`.

### High-level Overview

```
 your machine                          AWS (Learner Lab, us-east-1)
 ------------                          ----------------------------

 make deploy
   |
   |-- terraform apply  ---->  security group (ports 22 + 25565)
   |                           key pair + EC2 instance (Ubuntu 24.04, t3.medium)
   |                           writes the public IP into ansible/inventory.ini
   |
   '-- ansible-playbook ---->  install Docker
                               run itzg/minecraft-server (docker compose + systemd)
                               wait for port 25565

 make verify  ---->  nmap: 25565/tcp open  minecraft  CS 312 Minecraft Server
```

The steps in order:

1. Terraform creates the security group, uploads the SSH public key, and launches the instance.
2. Terraform writes the instance's public IP into `ansible/inventory.ini`.
3. Ansible connects over SSH and installs Docker and the Compose plugin.
4. Ansible templates out `docker-compose.yml` and a `minecraft.service` unit, then enables and starts it.
5. The container pulls the Minecraft server and starts listening on port 25565.
6. You confirm it with `nmap`.

### Running it

First time only, make the SSH key and the state bucket:

```
make setup
```

Then provision and configure in one shot:

```
make deploy
```

That runs `terraform apply` and then `ansible-playbook`, and prints the server address at the end. If you'd rather do the two stages separately:

```
make provision    # terraform: create the instance
make configure    # ansible: install and start the server
```

The Ansible run waits until port 25565 is actually accepting connections before it finishes, so when `make deploy` returns the server is really up. The first start takes a minute or two while it generates the world.

### Connecting to the server

Get the IP from the deploy output (or `terraform -chdir=terraform output -raw instance_public_ip`) and scan it:

```
nmap -sV -Pn -p T:25565 <public_ip>
```

You should see something like:

```
PORT      STATE SERVICE   VERSION
25565/tcp open  minecraft Minecraft 1.21.x (Protocol: ..., Message: CS 312 Minecraft Server, Users: 0/10)
```

`open` means the security group rule and the server are both working. The `Message` field is the MOTD coming back from the actual server, which proves the container is fully up and not just that the port is bound. `make verify` runs the same scan and fills in the IP for you.

To actually play, open Minecraft: Java Edition, go to **Multiplayer -> Add Server**, and put the public IP in the address field.

### Restart on reboot

The container runs with `restart: unless-stopped` and the `systemd` unit is enabled, so if the instance reboots the server comes back on its own. You can test that without SSH:

```
make reboot
```

Wait a minute, then run `make verify` again and it'll still be open.

### Shutting down properly

The Part 1 `systemd` unit had no stop logic, so stopping or rebooting just killed the Java process and the world didn't always save. The `itzg` image fixes the save itself: its entrypoint traps the stop signal and runs the in-game `stop` command first. The catch is you have to give it time, and Docker's default stop timeout is only 10 seconds. So:

- the compose file sets `stop_grace_period: 90s`, and
- the `systemd` unit uses `ExecStop=docker compose down --timeout 90` with `TimeoutStopSec=120`.

Because the unit is ordered `After=docker.service`, systemd stops Minecraft (and lets it save) before Docker itself shuts down on a reboot.

### GitHub Actions

`.github/workflows/deploy.yml` runs the same Terraform + Ansible on every push to `main` (there's also a `destroy.yml` you trigger by hand). Since Learner Lab credentials are temporary, set them as repository secrets and refresh them each session:

- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` from the same AWS Details panel.
- `SSH_PRIVATE_KEY`, the contents of `keys/minecraft-key`.

If the secrets have expired, the run fails at the AWS step. That's expected; just re-paste them.

### Teardown

```
make destroy
```

This removes the instance, security group, and key pair.
