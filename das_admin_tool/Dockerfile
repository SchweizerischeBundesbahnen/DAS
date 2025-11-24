FROM nginxinc/nginx-unprivileged:alpine-slim

# Copy nginx configuration
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

# Copy webapp
COPY ./dist/das_admin_tool/browser /usr/share/nginx/html

USER root

# Rename language directories from i. e. de-CH to de
RUN cd /usr/share/nginx/html && \
    for dir in *-CH; do \
        if [ -d "$dir" ]; then \
            mv "$dir" "${dir%-CH}"; \
        fi; \
    done && \
    ls -la

# Add write permission for random user for the index.html
RUN chmod a+w /usr/share/nginx/html/index.html

# Install ngssc binary
ADD https://github.com/kyubisation/angular-server-side-configuration/releases/download/v20.0.0/ngssc_64bit /usr/sbin/ngssc
RUN chmod +x /usr/sbin/ngssc

# Copy insert key script and assign execute permission
COPY ./ngssc.sh /docker-entrypoint.d/ngssc.sh
RUN chmod +x /docker-entrypoint.d/ngssc.sh

USER $UID
