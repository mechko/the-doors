# -------------------------------------
# Stage 1: Build the Vue.js app
# -------------------------------------
FROM node:25 AS build-stage

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build


# -------------------------------------
# Stage 2: Serve with Caddy
# -------------------------------------
FROM caddy:2.10.2-alpine AS production-stage

# Copy built Vue files to Caddy's default web root
COPY --from=build-stage /app/dist /usr/share/caddy

# Copy custom Caddy configuration
COPY Caddyfile /etc/caddy/Caddyfile

EXPOSE 80
EXPOSE 443

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]