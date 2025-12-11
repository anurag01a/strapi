# Docker Deep Dive

## 1. The Problem Docker Solves

Before Docker, applications faced the "it works on my machine" problem. Dependencies (libraries, OS versions, configs) varied between environments (development, testing, production), leading to deployment failures.
**Docker Solution**: It packages the application _and_ its dependencies (OS libs, runtime, code) into a single, immutable artifact called a **Container**. This ensures consistent behavior everywhere.

## 2. Virtual Machines vs Docker

| Feature       | Virtual Machines (VMs)                  | Docker Containers                            |
| :------------ | :-------------------------------------- | :------------------------------------------- |
| **OS**        | Each VM has a full Guest OS (heavy).    | Shares the Host OS kernel (lightweight).     |
| **Size**      | GBs (Gigabytes).                        | MBs (Megabytes).                             |
| **Startup**   | Minutes (boots OS).                     | Seconds (starts process).                    |
| **Isolation** | Hardware-level virtualization (Strong). | Process-level isolation (namespace/cgroups). |

## 3. Docker Architecture

When you install Docker, you get a Client-Server architecture:

1.  **Docker Client (`docker` CLI)**: The tool you use to type commands. It talks to the Daemon.
2.  **Docker Daemon (`dockerd`)**: The background process that manages images, containers, and networks.
3.  **Docker Registry**: A store for images (e.g., Docker Hub).
4.  **Objects**:
    - **Images**: Read-only templates (blueprints).
    - **Containers**: Running instances of images.

## 4. Dockerfile Deep Dive

A `Dockerfile` is a script of instructions to build an Image.

```dockerfile
# 1. Base Image: Start from a pre-built OS node image
FROM node:20-alpine

# 2. Working Directory: Create/Set the folder inside the container
WORKDIR /app

# 3. Copy Deps: Copy package files first to leverage caching
COPY package.json yarn.lock ./

# 4. Install: Run the install command inside the container
RUN yarn install --production

# 5. Copy Code: Copy the rest of the source code
COPY . .

# 6. Expose: Document which port the app listens on
EXPOSE 1337

# 7. Command: The default command to run when starting the container
CMD ["yarn", "start"]
```

## 5. Key Docker Commands

- `docker build -t name:tag .`: Build an image from a Dockerfile.
- `docker run -p 80:1337 image`: Run a container (map host port 80 to container 1337).
- `docker ps`: List running containers.
- `docker stop <id>`: Stop a container.
- `docker logs <id>`: View application logs.
- `docker exec -it <id> sh`: Open a shell inside a running container.

## 6. Docker Networking

Containers are isolated by default. To talk to each other, they need a **Network**.

- **Bridge Network**: The default private network on a single host.
- **User-defined Network**: Allows containers to resolve each other by name (e.g., `ping postgres`).
  - _Example_: In our setup, Strapi connects to `postgres:5432` because they share the `strapi-net`.

## 7. Volumes & Persistence

Containers are **ephemeral**. If you delete a container, its data is gone.
**Volumes** solve this by storing data _outside_ the container (on the host file system).

- **Named Volume**: `src:/var/lib/mysql` (Managed by Docker).
- **Bind Mount**: `./config:/app/config` (Maps a specific host folder to the container).

## 8. Docker Compose

A tool for defining and running multi-container Docker applications. Instead of running 3 separate `docker run` commands, you define services in `docker-compose.yml` and run:

- `docker-compose up -d`: Start all services in background.
- `docker-compose down`: Stop and remove all services.
