# Task 12: Docker Swarm & Cronjobs

## Table of Contents
- [Introduction to Docker Swarm](#introduction-to-docker-swarm)
- [Docker Swarm Architecture](#docker-swarm-architecture)
- [Setting Up Docker Swarm](#setting-up-docker-swarm)
- [Deploying Services](#deploying-services)
- [Scaling & Load Balancing](#scaling--load-balancing)
- [Cronjobs in Docker](#cronjobs-in-docker)
- [Best Practices](#best-practices)

---

## Introduction to Docker Swarm

**Docker Swarm** is Docker's native container orchestration tool that enables you to manage a cluster of Docker nodes as a single virtual system. It provides:

- **High Availability**: Automatic failover for containers
- **Horizontal Scaling**: Scale services up/down with a single command
- **Load Balancing**: Built-in ingress load balancing
- **Declarative Service Model**: Define desired state, Swarm maintains it
- **Rolling Updates**: Zero-downtime deployments

### When to Use Docker Swarm vs Kubernetes

| Feature | Docker Swarm | Kubernetes |
|---------|--------------|------------|
| Complexity | Simple, easy to learn | Steeper learning curve |
| Setup Time | Minutes | Hours/Days |
| Scaling | Good for small-medium | Enterprise-grade |
| Native Docker | Yes | Requires additional config |
| Best For | Small teams, quick deployments | Large-scale production |

---

## Docker Swarm Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      DOCKER SWARM CLUSTER                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────┐  ┌──────────────────┐                     │
│  │  MANAGER NODE 1  │  │  MANAGER NODE 2  │  (Raft Consensus)   │
│  │   (Leader)       │◄─►│   (Follower)     │                     │
│  └────────┬─────────┘  └──────────────────┘                     │
│           │                                                      │
│           │ Orchestration & Scheduling                          │
│           ▼                                                      │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                    WORKER NODES                          │   │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐         │   │
│  │  │  Worker 1  │  │  Worker 2  │  │  Worker 3  │         │   │
│  │  │ ┌────────┐ │  │ ┌────────┐ │  │ ┌────────┐ │         │   │
│  │  │ │Task 1  │ │  │ │Task 2  │ │  │ │Task 3  │ │         │   │
│  │  │ └────────┘ │  │ └────────┘ │  │ └────────┘ │         │   │
│  │  └────────────┘  └────────────┘  └────────────┘         │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                 OVERLAY NETWORK                          │   │
│  │         (Encrypted communication between nodes)          │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### Key Components

| Component | Description |
|-----------|-------------|
| **Manager Node** | Handles cluster management, scheduling, and API endpoints |
| **Worker Node** | Executes containers (tasks) as assigned by managers |
| **Service** | Definition of tasks to run on nodes |
| **Task** | A running container instance within a service |
| **Overlay Network** | Multi-host networking for swarm services |

---

## Setting Up Docker Swarm

### Step 1: Initialize Swarm on Manager Node

```bash
# Initialize swarm (run on manager node)
docker swarm init --advertise-addr <MANAGER_IP>

# Output will show a token for workers to join
```

**Example Output:**
```
Swarm initialized: current node (abc123) is now a manager.

To add a worker to this swarm, run:
    docker swarm join --token SWMTKN-1-xxxxx <MANAGER_IP>:2377
```

### Step 2: Join Worker Nodes

```bash
# Run on each worker node
docker swarm join --token SWMTKN-1-xxxxx <MANAGER_IP>:2377
```

### Step 3: Verify Cluster Status

```bash
# List all nodes
docker node ls

# Output
ID                            HOSTNAME   STATUS    AVAILABILITY   MANAGER STATUS
abc123 *                      manager1   Ready     Active         Leader
def456                        worker1    Ready     Active         
ghi789                        worker2    Ready     Active         
```

---

## Deploying Services

### Create a Simple Service

```bash
# Deploy nginx with 3 replicas
docker service create \
  --name web \
  --replicas 3 \
  --publish 80:80 \
  nginx:latest
```

### Using Docker Stack with Compose File

Create `docker-stack.yml`:

```yaml
version: "3.8"

services:
  strapi:
    image: strapi/strapi:latest
    ports:
      - "1337:1337"
    environment:
      DATABASE_CLIENT: postgres
      DATABASE_HOST: db
      DATABASE_PORT: 5432
      DATABASE_NAME: strapi
      DATABASE_USERNAME: strapi
      DATABASE_PASSWORD: strapi_password
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure
    networks:
      - strapi-network

  db:
    image: postgres:14-alpine
    environment:
      POSTGRES_DB: strapi
      POSTGRES_USER: strapi
      POSTGRES_PASSWORD: strapi_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    deploy:
      placement:
        constraints:
          - node.role == manager
    networks:
      - strapi-network

networks:
  strapi-network:
    driver: overlay
    attachable: true

volumes:
  postgres_data:
```

### Deploy the Stack

```bash
# Deploy stack
docker stack deploy -c docker-stack.yml strapi-app

# List stacks
docker stack ls

# List services in stack
docker stack services strapi-app

# View service logs
docker service logs strapi-app_strapi
```

---

## Scaling & Load Balancing

### Scale Services

```bash
# Scale to 5 replicas
docker service scale strapi-app_strapi=5

# OR update the service
docker service update --replicas 5 strapi-app_strapi
```

### Rolling Updates

```bash
# Update image with zero downtime
docker service update \
  --image strapi/strapi:v4.15.0 \
  --update-parallelism 1 \
  --update-delay 30s \
  strapi-app_strapi
```

### Built-in Load Balancing

Docker Swarm uses **Ingress Load Balancing** by default:

```
                    ┌─────────────────────┐
                    │   Client Request    │
                    │   (Port 1337)       │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │   Swarm Ingress     │
                    │   Load Balancer     │
                    └──────────┬──────────┘
                               │
            ┌──────────────────┼──────────────────┐
            ▼                  ▼                  ▼
    ┌───────────────┐  ┌───────────────┐  ┌───────────────┐
    │   Strapi 1    │  │   Strapi 2    │  │   Strapi 3    │
    │   (Worker 1)  │  │   (Worker 2)  │  │   (Worker 3)  │
    └───────────────┘  └───────────────┘  └───────────────┘
```

---

## Cronjobs in Docker

### Option 1: Using Host Crontab

Add to host's `/etc/crontab`:

```bash
# Run backup every day at 2 AM
0 2 * * * docker exec strapi_container npm run backup

# Clean logs every Sunday
0 0 * * 0 docker exec strapi_container rm -rf /app/logs/*.log
```

### Option 2: Dedicated Cron Container

Create `Dockerfile.cron`:

```dockerfile
FROM alpine:3.18

# Install required packages
RUN apk add --no-cache dcron curl

# Copy crontab file
COPY crontab /etc/crontabs/root

# Give execution permissions
RUN chmod 0644 /etc/crontabs/root

# Run crond in foreground
CMD ["crond", "-f", "-l", "2"]
```

Create `crontab` file:

```
# Cron job definitions
# MIN HOUR DAY MONTH WEEKDAY COMMAND

# Health check every 5 minutes
*/5 * * * * curl -s http://strapi:1337/_health || echo "Health check failed"

# Database backup daily at 3 AM
0 3 * * * /scripts/backup.sh >> /var/log/cron.log 2>&1

# Clean temp files every hour
0 * * * * find /tmp -type f -mmin +60 -delete
```

### Option 3: Swarm Service with Restart Policy

For periodic tasks in Swarm:

```yaml
version: "3.8"

services:
  backup-cron:
    image: myapp/backup:latest
    deploy:
      mode: replicated
      replicas: 1
      restart_policy:
        condition: on-failure
        delay: 5s
      placement:
        constraints:
          - node.role == manager
    environment:
      BACKUP_SCHEDULE: "0 3 * * *"
    volumes:
      - backup_data:/backups
    networks:
      - strapi-network

volumes:
  backup_data:
```

### Option 4: Using Ofelia (Docker Job Scheduler)

Create `docker-compose.cron.yml`:

```yaml
version: "3.8"

services:
  ofelia:
    image: mcuadros/ofelia:latest
    command: daemon --docker
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    labels:
      ofelia.job-run.backup.schedule: "0 3 * * *"
      ofelia.job-run.backup.container: "strapi_app"
      ofelia.job-run.backup.command: "npm run backup"
```

---

## Best Practices

### Docker Swarm Best Practices

| Practice | Description |
|----------|-------------|
| **Use Odd Number of Managers** | 3 or 5 managers for fault tolerance |
| **Separate Manager Workload** | Keep managers for orchestration only |
| **Use Overlay Networks** | For secure multi-host communication |
| **External Secrets** | Use `docker secret` for sensitive data |
| **Health Checks** | Always define health checks in services |
| **Resource Limits** | Set CPU/memory limits to prevent resource starvation |

### Cronjob Best Practices

| Practice | Description |
|----------|-------------|
| **Log Everything** | Redirect output to log files |
| **Use Lock Files** | Prevent overlapping job executions |
| **Handle Failures** | Implement retry logic and notifications |
| **Test Manually First** | Verify commands work before scheduling |
| **Use Absolute Paths** | Always use full paths in cron commands |

### Security Considerations

```yaml
# Example: Using Docker Secrets
services:
  strapi:
    image: strapi/strapi:latest
    secrets:
      - db_password
      - jwt_secret
    environment:
      DATABASE_PASSWORD_FILE: /run/secrets/db_password
      JWT_SECRET_FILE: /run/secrets/jwt_secret

secrets:
  db_password:
    external: true
  jwt_secret:
    external: true
```

---

## Quick Reference Commands

```bash
# Swarm Management
docker swarm init                    # Initialize swarm
docker swarm join-token worker       # Get worker join token
docker node ls                       # List nodes
docker node rm <node>                # Remove node

# Service Management
docker service create                # Create service
docker service ls                    # List services
docker service ps <service>          # List tasks of service
docker service scale <service>=N     # Scale service
docker service update                # Update service
docker service rm <service>          # Remove service

# Stack Management
docker stack deploy -c <file> <name> # Deploy stack
docker stack ls                      # List stacks
docker stack services <stack>        # List stack services
docker stack rm <stack>              # Remove stack

# Logs & Debugging
docker service logs <service>        # View service logs
docker node inspect <node>           # Inspect node details
```

---

## Summary

Docker Swarm provides a straightforward approach to container orchestration with:
- Built-in load balancing and service discovery
- Simple scaling and rolling updates
- Native Docker integration

For cronjobs in containerized environments:
- Host crontab for simple cases
- Dedicated cron containers for isolation
- Tools like Ofelia for Docker-native scheduling

This combination enables robust, scalable, and maintainable container deployments with scheduled task automation.
