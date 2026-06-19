FROM node:20-alpine AS frontend
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY index.html vite.config.ts tsconfig.json tailwind.config.js postcss.config.js ./
COPY public ./public
COPY src/frontend ./src/frontend
RUN npm run build

FROM ziglang/zig:0.13.0 AS backend
WORKDIR /app
COPY build.zig ./
COPY src/backend ./src/backend
RUN zig build -Doptimize=ReleaseSafe

FROM alpine:3.20
WORKDIR /app
COPY --from=backend /app/zig-out/bin/cloud-comment-backend /usr/local/bin/cloud-comment-backend
COPY --from=frontend /app/dist ./public
EXPOSE 8080
CMD ["cloud-comment-backend"]
