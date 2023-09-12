FROM alpine:3.18.0

# Install and configure Apache WebDAV and Subversion
RUN apk update && apk --no-cache add apache2 apache2-utils apache2-webdav mod_dav_svn subversion
RUN mkdir -p /run/apache2

RUN ln -sf /proc/self/fd/1 /var/log/apache2/access.log && \
    ln -sf /proc/self/fd/1 /var/log/apache2/error.log

ADD run.sh /
RUN chmod +x /run.sh

EXPOSE 80

# Define default command
CMD ["/run.sh"]