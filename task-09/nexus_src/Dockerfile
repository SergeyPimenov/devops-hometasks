FROM sonatype/nexus3:3.20.1

COPY ./nexus-start.sh /root/nexus-start.sh

COPY ./nexus-curl.sh /root/nexus-curl.sh 

USER root

RUN chmod +x  /root/nexus-curl.sh && chmod +x  /root/nexus-start.sh

COPY ./create_repo_raw_hosted.groovy /root/create_repo_raw_hosted.groovy

RUN touch /root/log

ENTRYPOINT  /root/nexus-start.sh


