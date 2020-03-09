FROM debian:buster

SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y ansible 

COPY ./playbook.yaml /root/playbook.yaml

RUN ansible-galaxy install geerlingguy.jenkins
RUN ansible-galaxy install geerlingguy.java
RUN ansible-playbook /root/playbook.yaml

COPY ./autorun.sh /root/autorun.sh

RUN chmod +x /root/autorun.sh  

ENTRYPOINT /root/autorun.sh



