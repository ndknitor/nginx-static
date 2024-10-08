Example usage:

```markdown
# Dockerfile
FROM ndknitor/nginx-static

# Set the working directory inside the container
WORKDIR /app

# Copy the contents of the local "app" directory to the container's working directory
COPY ./app .
```

## Example Run Command

Build the Docker image:

```bash
docker build -t example-static-web .
```

Run the Docker container, exposing ports 80 and 443, and mounting SSL certificates:

```bash
docker run -p 80:80 -p 443:443 -v /path/to/ssl/app.key:/ssl/app.key -v /path/to/ssl/app.crt:/ssl/app.crt -e WORKER_CONNECTIONS=2048 -e INDEX_WILDCARD_FORWARDING=1  example-static-web
```

This command runs the Docker container based on the built image, exposes ports 80 and 443 on the host machine, mounts the local SSL key and certificate files into the container, and sets the `WORKER_CONNECTIONS` environment variable to 2048.
