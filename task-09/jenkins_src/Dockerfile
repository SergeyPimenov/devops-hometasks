FROM debian:buster

SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y ansible apt-transport-https ca-certificates curl gnupg2 software-properties-common curl

USER root

RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"

RUN apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io 

RUN useradd jenkins && usermod -a -G docker jenkins  

COPY ./playbook.yaml /root/playbook.yaml

RUN ansible-galaxy install geerlingguy.jenkins && ansible-galaxy install geerlingguy.java && ansible-playbook /root/playbook.yaml

COPY ./autorun.sh /root/autorun.sh

RUN chmod +x /root/autorun.sh

RUN mkdir -p /var/lib/jenkins/workspace && chmod 777 /var/lib/jenkins/workspace 

ENTRYPOINT /root/autorun.sh



