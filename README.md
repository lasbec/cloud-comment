## Project Description

**cloud-comment** is a small, low-maintenance Markdown notes web application with pCloud integration. 
The application is designed as a frontend-focused progressiv web app (PWA) so it can be installed and used on Android similarly to a native app.
Access to pCloud is handled through a lightweight custom backend proxy instead of calling pCloud directly from the browser, due to limitations in the pCloud-API for browser applications.
Authentication uses the OAuth Code Flow; the pCloud access token is stored only on the server, while the frontend communicates via an HttpOnly session cookie.
The pCloud integration is intentionally kept small and implemented through a narrow custom API layer.

## Important Design desigions

* **pCloud API:** Will be implemented by the project, no SDK usage.
* **Authentication:** pCloud OAuth Code Flow, server-side token storage, HttpOnly session cookie
* **Deployment:** static frontend plus small backend service, both containerized in a Docker

## Component Overview

### Frontend

The frontend is a Vite-based TypeScript application with a lightweight Vanilla TypeScript UI and Tailwind for CSS tooling. 
It is responsible for the application shell, routing, login state, note list, editor view, preview area, and communication with the backend API.
Zod is used to validate API responses and internal data structures at runtime.

Technologies:
- npm
- TypeScript
- Vite
- Zod
- vite-plugin-pwa
- Web App Manifest
- Service Worker
- tailwind as CSS Tooling

### Editor Web Component

The editor is encapsulated as a dedicated Web Component.
This keeps the editor isolated from the rest of the application and makes it easier to replace or extend later. 
In the first version, the component is intentionally simple and internally uses a plain `<textarea>` as the editing surface.

Technologies:
- WebComponents

### Backend / Proxy

The backend is implemented in Zig and acts as a small proxy between the frontend and pCloud.
It handles authentication, session management, pCloud token storage, and all communication with the pCloud API.
The backend is wrapped in Docker to make deployment reproducible and independent from the host environment.

Technologies:
 - Zig
 - Docker
 - SQLite
## Build und Deployment

Das Frontend wird mit npm gebaut. Für ein lokales Produktions-Build:

```sh
npm install
npm run build
```

Das Deployment ist als Docker-Image vorgesehen. Das Image baut zuerst das Vite-Frontend, kompiliert anschließend den Zig-Backend-Proxy und startet den Container auf Port `8080`:

```sh
docker build -t cloud-comment .
docker run --rm -p 8080:8080 cloud-comment
```
