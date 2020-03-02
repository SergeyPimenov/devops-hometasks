FROM debian

SHELL ["/bin/bash", "-c"]

RUN apt-get update -y
RUN apt-get upgrade -y
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get install -y apt-utils php apache2
RUN rm /var/www/html/index.html
RUN chmod -R 777 /var/run/apache2

COPY ./index.php /var/www/html/index.php
COPY ./entrypoint.sh /tmp/entrypoint.sh

RUN chmod +x /tmp/entrypoint.sh
ENTRYPOINT /tmp/entrypoint.sh
