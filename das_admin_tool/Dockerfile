FROM nginxinc/nginx-unprivileged:alpine-slim

# Copy nginx configuration
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

# Copy webapp
COPY ./dist/das_admin_tool/browser /usr/share/nginx/html

USER root

# ngssc requires write permission for html files
RUN find /usr/share/nginx/html -name "index.html" -exec chmod a+w {} \; && \
    ls -R -la /usr/share/nginx/html

# Install ngssc binary
ADD https://github.com/kyubisation/angular-server-side-configuration/releases/download/v20.0.0/ngssc_64bit /usr/sbin/ngssc
RUN chmod +x /usr/sbin/ngssc

# Copy insert key script and assign execute permission
COPY ./ngssc.sh /docker-entrypoint.d/ngssc.sh
RUN chmod +x /docker-entrypoint.d/ngssc.sh

USER $UID
