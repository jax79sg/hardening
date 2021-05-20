#!/bin/bash
# exit when any command fails
set -e
PASSEDCOMPONENTS="01.Git, 02.APT16,04, 03.APT18.04, 04.DOCKERPUSH, 05.DOCKERPULL"
# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo -e "\"${last_command}\" command filed with exit code $?. \n     PASSEDCOMPONENTS: ${PASSEDCOMPONENTS}"' EXIT


GIT="01.Git"
APT16="02.APT1604"
APT18="03.APT1804"
DOCKERPUSH="04.DOCKERPUSH"
DOCKERPULL="05.DOCKERPULL"
CLEARMLREMOTE="06.CLEARMLREMOTE"
CLEARMLLOCAL="07.CLEARMLLOCAL"
CLEARMLUI="08.CLEARMLUI"
PIPINSTALL="09.PIPINSTALL"
PIPUPDATE="10.PIPUPDATE"
KUBEPOD="11.KUBE GET PODS"
KUBECREATE="12.KUBE CREATE"


success () {
  PASSEDCOMPONENTS="${PASSEDCOMPONENTS}, $1"
}

echo "--> Pulling the dependancies for tesing"
#git clone http://gitlab.dsta.ai/aiplatform/clienttest
git clone https://github.com/jax79sg/clearml-usage-examples
#cd clienttest
cd clearml-usage-examples
success "GIT"
echo "--> Building and pushing docker images"
docker build -t harbor.dsta.ai/public/ubuntu:dstaai.16.04 -f Dockerfile1604 .
PASSEDCOMPONENTS="${PASSEDCOMPONENTS}, APT 16.04"
docker push harbor.dsta.ai/public/ubuntu:dstaai.16.04
PASSEDCOMPONENTS="${PASSEDCOMPONENTS}, DOCKER PUSH"
docker build -t harbor.dsta.ai/public/ubuntu:dstaai.18.04 -f Dockerfile1804 .
PASSEDCOMPONENTS="${PASSEDCOMPONENTS}, APT 18.04"
docker push harbor.dsta.ai/public/ubuntu:dstaai.18.04
docker rmi -f harbor.dsta.ai/public/ubuntu:dstaai.18.04
docker pull harbor.dsta.ai/public/ubuntu:dstaai.18.04
fi
echo TESTING APT



