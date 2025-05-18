FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y bind9 dnsutils iputils-ping curl && \
    apt-get clean

COPY bind9 /etc/bind
COPY healthcheck.sh /healthcheck.sh
RUN chmod +x /healthcheck.sh

EXPOSE 53/udp 53/tcp

HEALTHCHECK CMD /healthcheck.sh

CMD ["named", "-g", "-u", "bind"]
