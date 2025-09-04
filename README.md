# Plex & Jellyfin Media Server Setup

This guide explains how to create Plex and Jellyfin media servers with distributed storage using JuiceFS and Scaleway object storage.

## Basic working principle

- Movies are stored in Object storages
- We trick Plex/Jellyfin into thinking the object storage is a normal local filesystem using JuiceFS
- JuiceFS stores some metadata in a SQLite database to help keep track of where things are
- JuiceFS uses FUSE (Filesystem in Userspace) to mount the cloud storage as a local directory

### Service Architecture

The system uses 4 systemd services with cascading dependencies:

```
sqlite-setup → juicefs-setup → juicefs-mount → plex/jellyfin
```

1. **sqlite-setup** - Creates SQLite database for JuiceFS metadata
1. **juicefs-setup** - Formats JuiceFS filesystem and creates mount directories
1. **juicefs-mount** - Mounts JuiceFS as FUSE filesystem
1. **plex/jellyfin** - Runs both media servers using the mounted filesystem

Starting/stopping either service automatically starts/stops all dependent services in the correct order.

## Basic installation principles

- Everything is managed via nix
- When the instance is created, it is instantly 'infected' with NixOS
- After the initial instance is completed
  - we need to update the user passwords for security reasons
  - we need to update the git repo with the latest hardware config, just to make sure the repo is up to date and contains a 'snapshot' of the machine's config
- Once the install is completed, we can apply config update simply by 'rebuilding' the system, there is no need to restart the installation from scratch
- The nix flake exposes all the variables in flake.nix for easy configuration

## Prerequisites

- Install Scaleway CLI: `curl -s https://raw.githubusercontent.com/scaleway/scaleway-cli/master/scripts/get.sh | sh`
- Configure authentication: `scw init`
- Set project ID environment variable: `export PROJECT_ID=XXXXX`
- Setup an a service API key for the project / organisation and keep both the access key and the secret key on hand

## Create object storage

Create a Scaleway bucket for JuiceFS distributed storage:

```bash
scw object bucket create name=<bucket-name> region=fr-par
```

## Create server & Infect it with NixOS

Create a server with sufficient resources for media streaming:

```bash
# 2 vCPU, 4GB RAM
scw instance server create \
  type=PLAY2-NANO \
  image=ubuntu_jammy \
  name=plex \
  zone=fr-par-2 \
  ip=ipv6 \
  project-id=$PROJECT_ID \
  cloud-init=@nixos-infect-cloud-init.yaml
```

## Get server IP and monitor installation

```bash
# Get the server IP and ID
scw instance server list zone=fr-par-2 project-id=$PROJECT_ID

# Set server IP and ID as variables for subsequent commands
export SERVER_IP=<server-ip>
export SERVER_ID=$(scw instance server list zone=fr-par-2 project-id=$PROJECT_ID -o json | jq -r '.[0].id')

# Poll for progression every minute

# Command will fail if nixos is not yet installed
ssh root@$SERVER_IP "nixos-version"

# Monitor NixOS installation progress (if still installing)
ssh root@$SERVER_IP "tail -f /tmp/infect.log"
```

## Deploy our NixOS configuration

### 1. Copy hardware configuration from remote server to local machine

```bash
scp root@$SERVER_IP:/etc/nixos/hardware-configuration.nix ./hardware-configuration.nix
```

### 2. From the local machine, commit hardware config to repository

```bash
git add hardware-configuration.nix
git commit -m "Add plex server hardware config"
git push
```

### 3. Clone repository on remote server

```bash
ssh root@$SERVER_IP "git clone https://github.com/ade-sede/media-center.git /var/lib/install"
```

### 4. Configure secrets

Edit `flake.nix` and replace the placeholder values with your actual Scaleway credentials:

```nix
# SECRETS - Fill these in but NEVER commit them
BUCKET_URL = "https://your-bucket-name.s3.fr-par.scw.cloud";
ACCESS_KEY = "your-scaleway-access-key"; 
SECRET_KEY = "your-scaleway-secret-key";
```

**Replace the placeholder values:**

- `your-bucket-name`: Your actual Scaleway bucket name
- `your-scaleway-access-key`: Your Scaleway access key
- `your-scaleway-secret-key`: Your Scaleway secret key

**⚠️ IMPORTANT**: Never commit these actual values to git. The secrets should only exist in your local working copy.

## Domain Configuration

Domains are hardcoded in `nix/nginx.nix`. To change them, edit the virtualHosts section:

- `plex.ade-sede.com` - Plex server (port 32400)
- `jellyfin.ade-sede.com` - Jellyfin server (port 8096)

Make sure your DNS records point to your server IP before rebuilding.

### 5. Deploy NixOS configuration

```bash
ssh root@$SERVER_IP "cd /var/lib/install && nixos-rebuild switch --flake .#plex"
```

**Note**: The SSL certificate generation will fail if the domain names are not setup yet. That's fine, you can simply rebuild later after making sure the domain name points toward the server.

## Update user passwords

After deployment, update the default passwords for security:

```bash
# SSH into the server and change passwords for each user
ssh ade-sede@$SERVER_IP  # default password: changeme
passwd ade-sede

ssh pancho@$SERVER_IP    # default password: changeme
passwd pancho
```

## Setup passwordless SSH access

Copy your SSH key to enable passwordless login:

```bash
# Set your preferred username
export USERNAME=ade-sede

# Copy SSH key for passwordless access
ssh-copy-id $USERNAME@$SERVER_IP
```

## qBittorrent Setup

qBittorrent-nox is configured to run automatically as a systemd service. The legal disclaimer is automatically accepted via the `--confirm-legal-notice` flag.

### WebUI Access

The WebUI is accessible via nginx reverse proxy at:

- **https://plex.ade-sede.com/torrent/**
- **https://jellyfin.ade-sede.com/torrent/**

### Initial Password Setup (Required)

On first access to the WebUI:

1. Login with username: `ade-sede` (no password required initially)
1. Go to Tools > Options > Web UI > Authentication
1. Set your desired WebUI password
1. The password will be permanently saved and remembered across restarts
