# ipmgr Examples# Example: Using ipmgr with Docker Compose



This directory contains comprehensive examples demonstrating how to use `ipmgr` for IP management in different scenarios.This example demonstrates how to allocate 3 IPs from a pool using `ipmgr`, save them into a `.env` file, and then bind three Nginx instances to each IP via Docker Compose.



## 📑 Table of Contents---



1. [Quick Start - Full Demo](#quick-start---full-demo)## Steps

2. [Docker Compose Example](#docker-compose-example)

3. [Kubernetes (kind) Integration](#kind-integration-example)### 1. Allocate 3 IPs from a pool

4. [Connectivity Testing](#connectivity-testing)

Run the following commands to allocate three IPs from the pool `172.21.22.100-172.21.22.105` on interface `eth0`:

---

```bash

## 🚀 Quick Start - Full Demosudo ipmgr alloc --pool 172.21.22.100-172.21.22.105 --iface eth0

sudo ipmgr alloc --pool 172.21.22.100-172.21.22.105 --iface eth0

Run everything at once with the full demo script:sudo ipmgr alloc --pool 172.21.22.100-172.21.22.105 --iface eth0

```

```bash

cd example### 2. Render allocations into `.env` file

./full-demo.sh

```Export the allocated IPs into a `.env` file:



This will:```bash

- ✅ Allocate 3 IPs for Nginx containersipmgr render-env --iface eth0 --prefix DEMO > .env

- ✅ Start 3 Nginx containers on dedicated IPs```

- ✅ Allocate 1 IP for kind Kubernetes cluster

- ✅ Create a kind cluster accessible on that IPExample `.env` file after allocation:

- ✅ Test connectivity between all components

```env

**Cleanup everything:**DEMO_IP1=172.21.22.100

DEMO_IP2=172.21.22.101

```bashDEMO_IP3=172.21.22.102

./cleanup-all.sh```

```

### 3. Run Docker Compose

---

Start the Nginx containers:

## 🐳 Docker Compose Example

```bash

### Overviewdocker-compose up -d

```

This example demonstrates how to allocate 3 IPs from a pool using `ipmgr`, save them into a `.env` file, and bind three Nginx instances to each IP via Docker Compose.

This will start three Nginx containers, each bound to one of the allocated IPs.

### Steps

### 4. Test connectivity

#### 1. Allocate 3 IPs from a pool

Verify that each IP responds with the Nginx welcome page:

Run the following commands to allocate three IPs from the pool on interface `docker0`:

```bash

```bash

../ipmgr alloc --pool 172.21.22.160-172.21.22.170 --iface docker0source .env

../ipmgr alloc --pool 172.21.22.160-172.21.22.170 --iface docker0

../ipmgr alloc --pool 172.21.22.160-172.21.22.170 --iface docker0curl http://$DEMO_IP1

```curl http://$DEMO_IP2

curl http://$DEMO_IP3

#### 2. Render allocations into `.env` file```



Export the allocated IPs into a `.env` file:---



```bash## Docker Compose File

../ipmgr render-env --iface docker0 --prefix DEMO > .env

```Save the following as `docker-compose.yml`:



Example `.env` file after allocation:```yaml

version: "3.9"

```env

DEMO_IP1=172.21.22.160services:

DEMO_IP2=172.21.22.161  nginx1:

DEMO_IP3=172.21.22.162    image: nginx:latest

```    ports:

      - "${DEMO_IP1}:80:80"

#### 3. Run Docker Compose

  nginx2:

Start the Nginx containers:    image: nginx:latest

    ports:

```bash      - "${DEMO_IP2}:80:80"

docker-compose up -d

```  nginx3:

    image: nginx:latest

This will start three Nginx containers, each bound to one of the allocated IPs.    ports:

      - "${DEMO_IP3}:80:80"

#### 4. Test connectivity```



Verify that each IP responds with the Nginx welcome page:---



```bash## Cleanup

source .env

When finished, run the cleanup script to stop containers and release IPs:

curl http://$DEMO_IP1

curl http://$DEMO_IP2Create a file `cleanup.sh`:

curl http://$DEMO_IP3

``````bash

#!/usr/bin/env bash

#### 5. Cleanupset -e



When finished, run the cleanup script to stop containers and release IPs:# Stop and remove containers

docker-compose down

```bash

./cleanup.sh# Release IPs from iface eth0 using ipmgr

```if [ -f .env ]; then

  source .env

---  for ip in "$DEMO_IP1" "$DEMO_IP2" "$DEMO_IP3"; do

    if [ -n "$ip" ]; then

## ☸️ Kind Integration Example      echo "Releasing $ip from eth0..."

      ipmgr release "$ip" --iface eth0

### Overview    fi

  done

This example shows how to integrate `ipmgr` with [kind (Kubernetes in Docker)](https://kind.sigs.k8s.io/) to create a Kubernetes cluster with a dedicated IP address. This is useful for:fi



- Running multiple kind clusters with unique IPsecho "Cleanup complete."

- Exposing Kubernetes API on a specific IP```

- Testing connectivity between containers and Kubernetes

Make it executable:

### Prerequisites

```bash

- `kind` installed ([installation guide](https://kind.sigs.k8s.io/docs/user/quick-start/#installation))chmod +x cleanup.sh

- `kubectl` installed```

- Docker running

Run cleanup:

### Steps

```bash

#### 1. Setup kind cluster with dedicated IP./cleanup.sh

```

Run the setup script:

---

```bash

./setup-kind.sh## Workflow Recap

```

1. Allocate 3 IPs with `ipmgr alloc`.

This script will:2. Export them into `.env` with `render-env`.

1. Allocate an IP from the pool `172.21.22.160-172.21.22.170` on interface `docker0`3. Run `docker-compose up -d` to start Nginx bound to each IP.

2. Generate a kind configuration with the allocated IP4. Test with `curl`.

3. Create a kind cluster named `ipmgr-demo`5. Run `cleanup.sh` to stop containers and release IPs.

4. Configure the Kubernetes API to listen on the allocated IP```



#### 2. Verify the cluster---


```bash
source kind.env
kubectl cluster-info
kubectl get nodes
```

Access the Kubernetes API on the dedicated IP:

```bash
curl -k https://$KIND_IP:5443
```

#### 3. View allocations

See all allocated IPs:

```bash
../ipmgr list-all
```

#### 4. Cleanup

Remove the kind cluster and release the IP:

```bash
./cleanup-kind.sh
```

### Kind Configuration

The `kind-config.yml` template configures:

- **API Server**: Listens on the allocated IP at port 5443
- **HTTP Port**: Maps port 80 to 8080 on the allocated IP
- **Certificates**: Includes the allocated IP in the certificate SANs

The actual configuration is generated at runtime with the allocated IP substituted.

---

## 🔍 Connectivity Testing

### Test Script

The `test-connectivity.sh` script performs comprehensive connectivity tests:

```bash
./test-connectivity.sh
```

**Tests performed:**

1. ✅ Kubernetes API accessibility from host
2. ✅ Nginx containers accessibility from host
3. ✅ Kubernetes API accessibility from Nginx containers
4. ✅ Nginx containers accessibility from kind containers

### Example Output

```
===================================
Testing Connectivity
===================================

Testing connectivity to Kubernetes API...
------------------------------------------
Testing: https://172.21.22.160:5443
✓ Kubernetes API is accessible at 172.21.22.160:5443

Testing connectivity to Nginx containers...
------------------------------------------
Testing: http://172.21.22.161... ✓ OK
Testing: http://172.21.22.162... ✓ OK
Testing: http://172.21.22.163... ✓ OK

Testing connectivity from Nginx container to Kubernetes API...
------------------------------------------------------------
Container: example-nginx1-1
Testing: curl from nginx1 to https://172.21.22.160:5443
✓ Nginx container can reach Kubernetes API at 172.21.22.160:5443

Testing connectivity from kind to Nginx containers...
----------------------------------------------------
Testing: curl from kind to http://172.21.22.161
✓ Kind container can reach nginx at 172.21.22.161
```

---

## 📁 Files Overview

| File | Description |
|------|-------------|
| `docker-compose.yml` | Docker Compose configuration for 3 Nginx containers |
| `kind-config.yml` | Template for kind cluster configuration |
| `setup-kind.sh` | Script to allocate IP and create kind cluster |
| `cleanup-kind.sh` | Script to delete kind cluster and release IP |
| `cleanup.sh` | Script to stop Docker Compose and release IPs |
| `test-connectivity.sh` | Comprehensive connectivity testing script |
| `full-demo.sh` | Complete demo running all examples |
| `cleanup-all.sh` | Complete cleanup of all resources |

---

## 🎯 Use Cases

### Development Environment

Use dedicated IPs for:
- Multiple kind clusters running simultaneously
- Isolated test environments
- Service mesh testing
- Multi-cluster scenarios

### CI/CD Pipelines

- Allocate IPs dynamically in CI/CD
- Run parallel test suites with isolated networks
- Clean up resources automatically

### Testing Network Policies

- Test connectivity between containers
- Verify Kubernetes network policies
- Simulate multi-node scenarios

---

## 🛠️ Troubleshooting

### "Cannot find device docker0"

Ensure Docker is running and the bridge network exists:

```bash
docker network ls
ip link show docker0
```

### "No free IPs in pool"

Increase the pool range or release unused IPs:

```bash
../ipmgr list-all
../ipmgr release <ip> --iface docker0
```

### Kind cluster creation fails

Check Docker resources and logs:

```bash
docker ps -a
kind get clusters
journalctl -u docker
```

### Connectivity tests fail

Verify IP allocations and container status:

```bash
../ipmgr list-all
docker ps
kubectl get nodes
```

---

## 📚 Additional Resources

- [kind Documentation](https://kind.sigs.k8s.io/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [ipmgr Main README](../README.md)

---

## 🤝 Contributing

Found an issue or want to add more examples? Contributions are welcome!

---

**Happy IP managing! 🎉**
