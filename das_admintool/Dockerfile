FROM nginxinc/nginx-unprivileged:alpine-slim

# Copy nginx configuration
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

# Copy webapp
COPY ./dist/das_admintool/browser /usr/share/nginx/html

USER root

# Add write permission for random user for the index.html
RUN chmod a+w /usr/share/nginx/html/index.html

# Install ngssc binary
ADD https://github.com/kyubisation/angular-server-side-configuration/releases/download/v20.0.0/ngssc_64bit /usr/sbin/ngssc
RUN chmod +x /usr/sbin/ngssc

# Copy insert key script and assign execute permission
COPY ./ngssc.sh /docker-entrypoint.d/ngssc.sh
RUN chmod +x /docker-entrypoint.d/ngssc.sh

USER $UID
