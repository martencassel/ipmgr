# ipmgr

**ipmgr** is a lightweight command-line tool for managing IP address allocations on network interfaces. It helps you allocate, track, and manage IP addresses across multiple network interfaces with a simple and intuitive interface.

## Features

✨ **Easy IP Management**
- Allocate IPs from a pool automatically
- Add specific IPs to interfaces
- Release IPs when no longer needed
- List allocations per interface or globally

📋 **Declarative Configuration**
- Define desired state in YAML files
- Apply configuration idempotently
- Validate config before applying
- Generate config from current state
- Show diffs between config and reality

🔍 **Subnet Detection & Validation**
- Automatically detect interface subnets
- Validate IPs against interface subnet
- Suggest appropriate IP pool ranges
- Prevent subnet misconfigurations

🎨 **Beautiful CLI**
- Colorful output for better readability
- Clean, organized layouts
- Progress indicators and status messages

📊 **State Tracking**
- Persistent state storage
- Track all IP allocations across reboots
- Export allocations as environment variables

## Installation

### Quick Install

```bash
# Clone the repository
git clone https://github.com/martencassel/ipmgr.git
cd ipmgr

# Make the script executable
chmod +x ipmgr

# (Optional) Install to your PATH
sudo cp ipmgr /usr/local/bin/
```

### Manual Installation

1. Download the `ipmgr` script
2. Make it executable: `chmod +x ipmgr`
3. Run it directly: `./ipmgr` or move it to a directory in your `$PATH`

## Requirements

- Bash shell
- `sudo` access (for adding/removing IPs from network interfaces)
- Linux system with `ip` command available
- `yq` (optional, only required for YAML configuration features)
  - Install: `brew install yq` (macOS) or `snap install yq` (Linux)

## Usage

### Basic Commands

```bash
# Show help
ipmgr

# Show interface details and get subnet information
ipmgr show-iface --iface docker0

# Allocate next free IP from a pool
ipmgr alloc --pool 192.168.1.10-192.168.1.20 --iface eth0

# Add a specific IP to an interface
ipmgr add 10.0.0.5 --iface eth1

# List IPs for a specific interface
ipmgr list --iface eth0

# List all IPs grouped by interface
ipmgr list-all

# Release an IP from an interface
ipmgr release 192.168.1.10 --iface eth0

# Export IPs as environment variables
eval $(ipmgr render-env --iface eth0 --prefix MYAPP)
```

### Declarative Configuration

```bash
# Generate a config file from current state
ipmgr generate

# Create or edit ipmgr.yaml with your desired state
cat > ipmgr.yaml << 'EOF'
interfaces:
  - name: eth0
    ips:
      - 192.168.1.10
      - 192.168.1.11
  - name: docker0
    ips:
      - 172.17.0.100
      - 172.17.0.101
EOF

# Validate the configuration
ipmgr validate

# Show what would change
ipmgr diff

# Apply the configuration
ipmgr apply

# Use a different config file
ipmgr apply --config custom.yaml
```

## Examples

### Discovering Interface Subnets

Before allocating IPs, check what subnet is configured on your interface:

```bash
$ ipmgr show-iface --iface docker0

  Interface Details: docker0

Status: UP

Configured Subnets:

  172.17.0.1/16 (scope: global)
  ├─ Network:   172.17.0.0
  ├─ Broadcast: 172.17.255.255
  └─ Usable:    ~65534 hosts

Suggested Pool Range:

  172.17.0.10-172.17.255.254

Example usage:
  ipmgr alloc --pool 172.17.0.10-172.17.255.254 --iface docker0
```

This command shows:
- Interface status (UP/DOWN)
- All configured subnets with CIDR notation
- Network and broadcast addresses
- Number of usable hosts
- **Suggested pool range** that's safe to use

### Automatic Subnet Validation

ipmgr automatically validates that IPs are in the correct subnet:

```bash
# Try to add an IP from the wrong subnet
$ ipmgr add 192.168.1.100 --iface docker0
✗ IP 192.168.1.100 is not in the subnet of docker0

Interface subnet: 172.17.0.1/16
Suggested pool:   172.17.0.10-172.17.255.254

# Use the correct subnet
$ ipmgr add 172.17.0.50 --iface docker0
✓ Allocated 172.17.0.50 on docker0
```

### Allocating IPs from a Pool

```bash
# Allocate the next free IP from the pool to eth0
$ ipmgr alloc --pool 192.168.1.10-192.168.1.20 --iface eth0
✓ Allocated 192.168.1.10 on eth0

# Allocate another IP
$ ipmgr alloc --pool 192.168.1.10-192.168.1.20 --iface eth0
✓ Allocated 192.168.1.11 on eth0
```

### Adding Specific IPs

```bash
# Add a specific IP to an interface
$ ipmgr add 10.0.0.5 --iface eth1
✓ Allocated 10.0.0.5 on eth1
```

### Listing Allocations

```bash
# List IPs for a specific interface
$ ipmgr list --iface eth0
Interface: eth0
────────────────────────────
  192.168.1.10
  192.168.1.11
  (2 IP(s) allocated)

# List all IPs across all interfaces
$ ipmgr list-all

  IP Allocations by Interface

┌─ Interface: eth0
│  192.168.1.10
│  192.168.1.11
└─ 2 IP(s)

┌─ Interface: eth1
│  10.0.0.5
└─ 1 IP(s)

═══════════════════════════════
Summary: 2 interface(s), 3 IP(s) total
```

### Releasing IPs

```bash
# Release an IP from an interface
$ ipmgr release 192.168.1.10 --iface eth0
✓ Released 192.168.1.10 from eth0
```

### Environment Variable Export

```bash
# Export IPs as environment variables
$ ipmgr render-env --iface eth0 --prefix MYAPP
MYAPP_IP1=192.168.1.10
MYAPP_IP2=192.168.1.11

# Use eval to export them to your shell
$ eval $(ipmgr render-env --iface eth0 --prefix MYAPP)
$ echo $MYAPP_IP1
192.168.1.10
```

### Declarative Configuration Workflow

ipmgr supports a GitOps-style declarative workflow using YAML configuration files.

#### 1. Generate Config from Current State

```bash
# Generate ipmgr.yaml from currently allocated IPs
$ ipmgr generate
✓ Generated config: ./ipmgr.yaml
  2 interface(s), 5 IP(s)

$ cat ipmgr.yaml
# ipmgr configuration file
# Generated from current state on Wed Nov 13 2025

interfaces:
  - name: docker0
    ips:
      - 172.17.0.10
      - 172.17.0.11
  - name: eth0
    ips:
      - 192.168.1.10
      - 192.168.1.11
      - 192.168.1.12
```

#### 2. Edit Your Desired State

```bash
# Edit ipmgr.yaml to define your desired state
$ cat > ipmgr.yaml << 'EOF'
interfaces:
  - name: docker0
    ips:
      - 172.17.0.10
      - 172.17.0.11
      - 172.17.0.12  # Added new IP
  - name: eth0
    ips:
      - 192.168.1.10
      - 192.168.1.11
      # Removed 192.168.1.12
EOF
```

#### 3. Validate Configuration

```bash
$ ipmgr validate

Validating ipmgr.yaml

✓ YAML syntax valid
✓ Found 2 interface(s)

Interface: docker0
  ✓ Interface exists
  3 IP(s) defined

Interface: eth0
  ✓ Interface exists
  2 IP(s) defined

═══════════════════════════════
✓ Validation passed
  2 interface(s), 5 IP(s) defined
```

#### 4. Preview Changes

```bash
$ ipmgr diff

Configuration Diff
Shows what would change if config is applied

To be added:
  + docker0 172.17.0.12

Not in config (would remain):
  ○ eth0 192.168.1.12

═══════════════════════════════
Summary:
  1 to be added
  4 already present
  1 not in config
```

#### 5. Apply Configuration

```bash
$ ipmgr apply

Applying configuration from ipmgr.yaml

Interface: docker0
  ○ 172.17.0.10 (already allocated)
  ○ 172.17.0.11 (already allocated)
  ✓ 172.17.0.12 allocated

Interface: eth0
  ○ 192.168.1.10 (already allocated)
  ○ 192.168.1.11 (already allocated)

═══════════════════════════════
Summary: 1 applied, 4 skipped, 0 failed
```

#### 6. Use in CI/CD

```bash
# In your deployment pipeline
ipmgr validate --config production.yaml
ipmgr diff --config production.yaml
ipmgr apply --config production.yaml
```

### Managing Multiple Environments

```bash
# Development environment
$ cat > ipmgr-dev.yaml << 'EOF'
interfaces:
  - name: docker0
    ips:
      - 172.17.0.100
      - 172.17.0.101
EOF

# Production environment
$ cat > ipmgr-prod.yaml << 'EOF'
interfaces:
  - name: eth0
    ips:
      - 192.168.1.100
      - 192.168.1.101
      - 192.168.1.102
EOF

# Apply specific environment
$ ipmgr apply --config ipmgr-dev.yaml
$ ipmgr apply --config ipmgr-prod.yaml
```

## State File

All IP allocations are stored in `~/.ipmgr_state`. This file persists across system reboots and allows you to track which IPs are allocated to which interfaces.

Format: `<interface> <ip_address>`

Example:
```
eth0 192.168.1.10
eth0 192.168.1.11
eth1 10.0.0.5
```

## Docker Example

See the `example/` directory for a complete Docker Compose setup demonstrating how to use ipmgr in a containerized environment.

## Use Cases

- **Container Networking**: Allocate IPs for Docker containers or VMs
- **Testing Environments**: Quickly set up multiple IPs for testing
- **Service Deployment**: Manage IPs for multiple services on different interfaces
- **Development**: Create isolated network environments
- **GitOps/IaC**: Define infrastructure as code with YAML configs
- **CI/CD Pipelines**: Automate IP allocation in deployment workflows

## Troubleshooting

### Permission Denied

If you get permission errors, ensure:
1. The script is executable: `chmod +x ipmgr`
2. You have sudo access (required for `ip addr add/del` commands)

### No Such Device

If you get "Cannot find device" errors:
- Verify the network interface exists: `ip link show`
- Use the correct interface name (e.g., `eth0`, `enp0s3`, `docker0`)

### Wrong Subnet Error

If you see "IP is not in the subnet" error:

```bash
✗ IP 192.168.1.100 is not in the subnet of docker0

Interface subnet: 172.17.0.1/16
Suggested pool:   172.17.0.10-172.17.255.254
```

**Solution**: Use `ipmgr show-iface --iface <interface>` to see the correct subnet and use IPs from that range.

**Why this happens**: Each network interface has a configured subnet (e.g., `172.17.0.0/16`). You can only add IPs that belong to that subnet. The tool automatically validates this and suggests the correct range.

### IPs Not Persisting

IP addresses added by `ipmgr` will persist until:
- They are explicitly released with `ipmgr release`
- The network interface is brought down
- The system is rebooted (depending on your network configuration)

For permanent IP configuration, consider using your system's network management tools.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - feel free to use this tool in your projects!

## Author

Mårten Cassel

---

**Note**: This tool directly modifies network interfaces using the `ip` command. Always test in a safe environment before using in production.
