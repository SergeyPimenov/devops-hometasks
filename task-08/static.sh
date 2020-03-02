#!/bin/bash
docker run --rm -d --name "static_site" -p 8081:80 -v `dirname $0`/index.html:/var/www/html/index.html hometask-image


