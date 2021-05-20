#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
# exit when any command fails
set -e
# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo -e "\n\"${last_command}\" command filed with exit code $?. \n\nComponents not tested or failed: ${FAILEDCOMPONENTS}\n"' EXIT


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

FAILEDCOMPONENTS="${GIT} ${APT16} ${APT18} ${DOCKERPUSH} ${DOCKERPULL} ${CLEARMLREMOTE} ${CLEARMLLOCAL} ${CLEARMLUI} ${PIPINSTALL} ${PIPUPDATE} ${KUBEPOD} ${KUBECREATE}"

success () {
  echo -e "${GREEN}\nSUCCESS!: $1 \n${NC}"
  FAILEDCOMPONENTS=${FAILEDCOMPONENTS#"$1"}
}

gittest () {
  git clone $1
  foo=$1
  folder=${foo##*/}
  cd ${folder}
  touch test.tst
  git add test.tst
  git commit -a -m "test"
  git push   
  rm test.txt
  git commit -a -m "test"
  git push
  success ${GIT}
}

#git clone http://gitlab.dsta.ai/aiplatform/clienttest
gittest  https://github.com/jax79sg/clearml-usage-examples
#cd clienttest
#cd clearml-usage-examples
#success ${GIT}
echo "--> Building and pushing docker images"
docker build -t harbor.dsta.ai/public/ubuntu:dstaai.16.04 -f Dockerfile1604 .
FAILEDCOMPONENTS="${FAILEDCOMPONENTS}, APT 16.04"
docker push harbor.dsta.ai/public/ubuntu:dstaai.16.04
FAILEDCOMPONENTS="${FAILEDCOMPONENTS}, DOCKER PUSH"
docker build -t harbor.dsta.ai/public/ubuntu:dstaai.18.04 -f Dockerfile1804 .
FAILEDCOMPONENTS="${FAILEDCOMPONENTS}, APT 18.04"
docker push harbor.dsta.ai/public/ubuntu:dstaai.18.04
docker rmi -f harbor.dsta.ai/public/ubuntu:dstaai.18.04
docker pull harbor.dsta.ai/public/ubuntu:dstaai.18.04
fi
echo TESTING APT



