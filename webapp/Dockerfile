FROM nginxinc/nginx-unprivileged:stable

#### copy nginx conf
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

#### copy artifact build
COPY ./dist/webapp /usr/share/nginx/html
