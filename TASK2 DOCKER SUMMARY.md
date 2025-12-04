# Task 2 — Docker Summary

This document outlines the containerization choices made for the Strapi monorepo exercise and the example app under `examples/getstarted`.

Summary

- Base image: `node:20-alpine` chosen for small size and Node 20 compatibility.
- Build strategy: multi-stage builds to keep final images minimal and copy only runtime artifacts.
- Ports: container exposes `1337` (Strapi default) for the example app.
- User: a non-root `appuser` is created for safer runtime.

Why this layout

- Root `Dockerfile` targets monorepo use — installs dependencies once and can build multiple packages.
- `examples/getstarted/Dockerfile` (in this repo) is a compact runtime image focusing on a single app.

How to use

1. Build root image (monorepo):
   - `docker build -t strapi-monorepo -f Dockerfile .`
2. Build example app image:
   - `docker build -t strapi-example -f examples/getstarted/Dockerfile examples/getstarted`

Notes

- `NODE_ENV` is left as `development` in these examples to match local development expectations; change to `production` in CI/CD.
- If your repository uses `pnpm` or `yarn`, adjust the install commands accordingly.
