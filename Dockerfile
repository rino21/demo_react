FROM node:latest AS builder

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build

FROM nginx:latest

# Créer un utilisateur non-root avec les permissions nécessaires
RUN useradd -u 1001 -g 0 -s /bin/sh -m nginx && \
    chown -R nginx:0 /var/cache/nginx /var/run /var/log/nginx /etc/nginx && \
    chmod -R g+rwx /var/cache/nginx /var/run /var/log/nginx /etc/nginx

# Supprimer les fichiers par défaut
RUN rm -rf /usr/share/nginx/html/*

# Copier les fichiers buildés
COPY --from=builder /app/dist /usr/share/nginx/html/

# Donner les permissions sur le dossier html
RUN chown -R nginx:0 /usr/share/nginx/html && \
    chmod -R g+rwx /usr/share/nginx/html

EXPOSE 8080

# Utiliser l'utilisateur non-root
USER 1001

CMD ["nginx", "-g", "daemon off;"]