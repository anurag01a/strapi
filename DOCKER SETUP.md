# Docker Setup — examples/getstarted

Steps to build and run the example app container locally.

1. Build the image from the example folder:

```powershell
docker build -t strapi-getstarted -f examples/getstarted/Dockerfile examples/getstarted
```

2. Run the container, mapping port 1337:

```powershell
docker run --rm -p 1337:1337 --name strapi-local strapi-getstarted
```

Notes:

- If you use environment variables, pass them with `-e NAME=value` or a `.env` file.
- Adjust `NODE_ENV` to `production` for production images.
