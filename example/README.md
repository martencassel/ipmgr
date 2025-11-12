# Example: Using ipmgr with Docker Compose

This example demonstrates how to allocate 3 IPs from a pool using `ipmgr`, save them into a `.env` file, and then bind three Nginx instances to each IP via Docker Compose.

---

## Steps

### 1. Allocate 3 IPs from a pool

Run the following commands to allocate three IPs from the pool `172.21.22.100-172.21.22.105` on interface `eth0`:

```bash
sudo ipmgr alloc --pool 172.21.22.100-172.21.22.105 --iface eth0
sudo ipmgr alloc --pool 172.21.22.100-172.21.22.105 --iface eth0
sudo ipmgr alloc --pool 172.21.22.100-172.21.22.105 --iface eth0
```

### 2. Render allocations into `.env` file

Export the allocated IPs into a `.env` file:

```bash
ipmgr render-env --iface eth0 --prefix DEMO > .env
```

Example `.env` file after allocation:

```env
DEMO_IP1=172.21.22.100
DEMO_IP2=172.21.22.101
DEMO_IP3=172.21.22.102
```

### 3. Run Docker Compose

Start the Nginx containers:

```bash
docker-compose up -d
```

This will start three Nginx containers, each bound to one of the allocated IPs.

### 4. Test connectivity

Verify that each IP responds with the Nginx welcome page:

```bash

source .env

curl http://$DEMO_IP1
curl http://$DEMO_IP2
curl http://$DEMO_IP3
```

---

## Docker Compose File

Save the following as `docker-compose.yml`:

```yaml
version: "3.9"

services:
  nginx1:
    image: nginx:latest
    ports:
      - "${DEMO_IP1}:80:80"

  nginx2:
    image: nginx:latest
    ports:
      - "${DEMO_IP2}:80:80"

  nginx3:
    image: nginx:latest
    ports:
      - "${DEMO_IP3}:80:80"
```

---

## Cleanup

When finished, run the cleanup script to stop containers and release IPs:

Create a file `cleanup.sh`:

```bash
#!/usr/bin/env bash
set -e

# Stop and remove containers
docker-compose down

# Release IPs from iface eth0 using ipmgr
if [ -f .env ]; then
  source .env
  for ip in "$DEMO_IP1" "$DEMO_IP2" "$DEMO_IP3"; do
    if [ -n "$ip" ]; then
      echo "Releasing $ip from eth0..."
      ipmgr release "$ip" --iface eth0
    fi
  done
fi

echo "Cleanup complete."
```

Make it executable:

```bash
chmod +x cleanup.sh
```

Run cleanup:

```bash
./cleanup.sh
```

---

## Workflow Recap

1. Allocate 3 IPs with `ipmgr alloc`.
2. Export them into `.env` with `render-env`.
3. Run `docker-compose up -d` to start Nginx bound to each IP.
4. Test with `curl`.
5. Run `cleanup.sh` to stop containers and release IPs.
```

---
