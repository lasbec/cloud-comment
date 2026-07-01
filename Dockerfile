FROM node:20-alpine AS frontend
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY index.html vite.config.ts tsconfig.json tailwind.config.js postcss.config.js ./
COPY public ./public
COPY src/frontend ./src/frontend
RUN npm run build

FROM debian:bookworm-slim AS backend
WORKDIR /app
ARG TARGETARCH
ARG ZIG_VERSION=0.13.0
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl xz-utils \
    && rm -rf /var/lib/apt/lists/* \
    && TARGETARCH="${TARGETARCH:-$(dpkg --print-architecture)}" \
    && case "${TARGETARCH}" in \
        amd64) ZIG_ARCH="x86_64" ;; \
        arm64) ZIG_ARCH="aarch64" ;; \
        *) echo "Unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
    esac \
    && curl -fsSL "https://ziglang.org/download/${ZIG_VERSION}/zig-linux-${ZIG_ARCH}-${ZIG_VERSION}.tar.xz" -o /tmp/zig.tar.xz \
    && mkdir -p /opt/zig \
    && tar -xJf /tmp/zig.tar.xz -C /opt/zig --strip-components=1 \
    && rm /tmp/zig.tar.xz
ENV PATH="/opt/zig:${PATH}"
COPY build.zig ./
COPY src/backend ./src/backend
RUN zig build -Doptimize=ReleaseSafe

FROM alpine:3.20
WORKDIR /app
COPY --from=backend /app/zig-out/bin/cloud-comment-backend /usr/local/bin/cloud-comment-backend
COPY --from=frontend /app/dist ./public
EXPOSE 8080
CMD ["cloud-comment-backend"]
