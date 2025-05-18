FROM smallstep/step-ca:latest

COPY entrypoint.sh /entrypoint.sh
USER root
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
