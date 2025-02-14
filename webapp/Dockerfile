FROM nginxinc/nginx-unprivileged:stable

USER root

# Install ngssc binary
ADD https://github.com/kyubisation/angular-server-side-configuration/releases/download/v18.2.0/ngssc_64bit /usr/sbin/ngssc
RUN chmod +x /usr/sbin/ngssc

#### copy nginx conf
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

# Add ngssc init script
COPY ngssc.sh /docker-entrypoint.d/ngssc.sh
RUN chmod +x /docker-entrypoint.d/ngssc.sh

#### copy artifact build
COPY ./dist/webapp /usr/share/nginx/html

USER $UID
