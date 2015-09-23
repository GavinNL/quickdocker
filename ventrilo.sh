#!/bin/bash
docker rm -f ventrilo
docker run --publish-all=true --privileged=true --name ventrilo -d -p 3784:3784 -p 3784:3784/udp akursar/ventrilo
