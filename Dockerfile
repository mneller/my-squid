# Squid container
# from Chris H <chris@trash.co.nz>
# Source: https://github.com/kiwichrish/alpine_squid

FROM alpine:latest
LABEL maintainer="martin@ellermeier.net"

EXPOSE 3128/tcp

RUN apk update \
    && apk upgrade \
    && apk add --update --no-cache  squid tzdata \
    && mkdir /etc/squid.dist \
    && mv /etc/squid/* /etc/squid.dist/

ADD squid.conf /etc/squid.dist/squid.conf
ADD startup.sh /startup.sh
RUN chmod +x /startup.sh

# Simple health Check
HEALTHCHECK CMD netstat -an | grep 3128 > /dev/null; if [ 0 != $? ]; then exit 1; fi;

VOLUME /squid
VOLUME /etc/squid
VOLUME /var/log/squid

ENTRYPOINT ["/startup.sh"]