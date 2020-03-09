#!/bin/bash
echo "Start script"
until [[ -n $(cat /nexus-data/log/nexus.log | grep "Started Sonatype Nexus") ]]
do
sleep 1
done

curl -u admin:`cat /nexus-data/admin.password`  -X PUT "http://localhost:8081/service/rest/beta/security/users/admin/change-password" -H "accept: application/json" -H "Content-Type: text/plain" -d "admin"


DATA_SCRIPT() {
    cat <<EOF
$(cat /root/create_repo_raw_hosted.groovy | sed ':a;N;$!ba;s/\n/\\n/g')
EOF
  }


# экранируем символы, заменяя "\n" на "\\n"

curl -u admin:admin -X POST "http://localhost:8081/service/rest/v1/script" -H "accept: application/json" -H "Content-Type: application/json" -d "{ \"name\": \"create-repository\", \"content\": \"$(DATA_SCRIPT)\", \"type\": \"groovy\"}"

curl -u admin:admin -X POST "http://localhost:8081/service/rest/v1/script/create-repository/run" -H "accept: application/json" -H "Content-Type: text/plain"

curl -u admin:admin -X DELETE "http://localhost:8081/service/rest/v1/script/create-repository" -H "accept: application/json"