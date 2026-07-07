FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:stable-alpine AS production

RUN mkdir -p /var/run/nginx && \
    chown -R nginx:nginx /var/cache/nginx /var/run/nginx /usr/share/nginx/html && \
    chmod -R g+w /var/cache/nginx

COPY --from=builder --chown=nginx:nginx /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

USER nginx

EXPOSE 5173

# Démarrer Nginx
CMD ["nginx", "-g", "daemon off;"]