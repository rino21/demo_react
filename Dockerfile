FROM node:latest AS builder

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build


FROM nginx:alpine

RUN rm -rf /usr/share/nginx/html/*

COPY --from=builder /app/dist /usr/share/nginx/html/

COPY nginx.conf /etc/nginx/conf.d/default.conf


# Permissions OpenShift
RUN mkdir -p /var/cache/nginx/client_temp \
    && mkdir -p /var/run/nginx \
    && chmod -R 777 /var/cache/nginx \
    && chmod -R 777 /var/run/nginx \
    && chmod -R 777 /usr/share/nginx/html


EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]