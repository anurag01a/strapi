# Task 4 - Docker Deep Dive

## 1) The Problem Docker Solves

Before Docker, developers faced challenges due to differences in **Operating Systems**, **Dependency Versions**, **Installed Libraries**, and **Environment Configurations**. These inconsistencies often led to the "it works on my machine" problem.

Docker addresses these issues by providing:

- Lightweight, portable containers
- Consistent environments across systems
- Fast startup times
- Simplified deployment and scaling
- Isolation without requiring a full OS

Docker ensures applications are portable, consistent, and easy to run anywhere.

## 2) Virtual Machines vs Docker Containers

### Virtual Machines (VMs)

- Require a full guest OS (e.g., Ubuntu, Windows) for each VM
- Heavy in terms of resource usage (RAM, disk space)
- Slow to boot (minutes)
- Provide hardware-level isolation
- Suitable for complete OS simulation

### Docker Containers

- Share the host OS kernel
- Lightweight (MBs)
- Start almost instantly (milliseconds)
- Provide process-level isolation
- Ideal for microservices and DevOps workflows

## 3) Understanding Docker Architecture

### Key Components of Docker

When Docker is installed, the following components are added:

- **Docker Daemon (`dockerd`)**: Manages containers, images, networks, and volumes.
- **Docker CLI (`docker` command)**: Command-line interface for interacting with Docker.
- **Container Runtime (`runc`)**: Handles the low-level operations of running containers.
- **Containerd**: Manages the container lifecycle.
- **Storage Drivers**: Manage image layers and container filesystems.
- **Network Drivers**: Enable communication between containers.

## 4) Dockerfile Deep Dive

### Example Dockerfile

```Dockerfile
# Base image
FROM node:18-alpine

# Working directory
WORKDIR /app

# Copy package files first
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY . .

# Expose app port
EXPOSE 3000

# Start the application
CMD ["npm", "start"]
```

- `FROM`: Specifies the base image.
- `WORKDIR`: Sets the working directory inside the container.
- `COPY`: Copies files into the container.
- `RUN`: Executes commands during the image build process.
- `EXPOSE`: Documents the ports the container listens on.
- `CMD`: Specifies the default command to run in the container.

## 5) Key Docker Commands

### Managing Images

```bash
docker pull <image>
docker images
docker rmi <image>
```

### Managing Containers

```bash
docker run <image>
docker run -p 8080:80 nginx
docker ps
docker stop <container>
docker rm <container>
docker logs <container>
```

### Building Images

```bash
docker build -t myapp .
```

### Executing Commands in Containers

```bash
docker exec -it <container> sh
```

## 6) Docker Networking

Docker provides several networking options:

- **Bridge Network**: Default network for container-to-container communication on the same host.
- **Host Network**: Shares the host’s networking stack.
- **Overlay Network**: Used in multi-host environments.

### Example

```bash
docker network create mynet
docker run --network=mynet ...
```

## 7) Volumes & Persistence

Docker containers are stateless by default. Volumes provide a way to persist data beyond the lifecycle of a container.

### Types of Docker Storage

- **Volumes**: Managed by Docker and stored in `/var/lib/docker/volumes/`.
- **Bind Mounts**: Map a host directory to a container directory.
- **tmpfs Mounts**: Store data in memory (RAM).

### Example

```bash
docker volume create myvolume
docker run -v myvolume:/app/data myimage
```

## 8) Docker Compose

Docker Compose simplifies the management of multi-container applications using a `docker-compose.yml` file.

### Common Commands

```bash
docker-compose up
docker-compose down
docker-compose build
docker-compose logs
```

### Example Configuration

```yaml
version: "3.8"

services:
  app:
    build: .
    ports:
      - "3000:3000"
    depends_on:
      - db

  db:
    image: postgres:16
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: appdb
    volumes:
      - dbdata:/var/lib/postgresql/data

volumes:
  dbdata:
```
