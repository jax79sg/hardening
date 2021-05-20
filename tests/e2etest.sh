#/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

FAILEDCOMPONENT=""
GITLINK="https://github.com/jax79sg/clearml-usage-examples"
GITFOLDER=${GITLINK##*/}
#GITFOLDER="hardening"
UBUNTU1804IMAGE="ubuntu:18.04"
UBUNTU1604IMAGE="ubuntu:16.04"
PINGLIST="www.google.com www.yahoo.com"
DOCKERREPO="docker.io"
PUSHPULLIMAGE="quay.io/jax79sg/afro-mnt:fake"
CLEARMLSERVER="mlops.sytes.net:8080"
KUBEPODDEPLOY="pod-httpd"

### Setting up
if [ "$(docker images | grep myubuntu:18.04)" != "" ]; then
   docker rmi -f myubuntu:16.04
fi

if [ "$(docker images | grep myubuntu:18.04)" != "" ]; then
   docker rmi -f myubuntu:18.04
fi

if [ -d ${GITFOLDER} ]; then
   sudo rm -r ${GITFOLDER}
fi

shopt -s extdebug
# exit when any command fails
set -e
# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo -e "\n${RED}${last_command} command failed. \n\n Components not tested or failed: ${FAILEDCOMPONENTS}${NC} "' EXIT


GIT="01.Git"
APT16="02.APT1604"
APT18="03.APT1804"
DOCKERBUILD="DOCKERBUILD"
DOCKERPUSH="04.DOCKERPUSH"
DOCKERPULL="05.DOCKERPULL"
CLEARMLREMOTE="06.CLEARMLREMOTE"
CLEARMLLOCAL="07.CLEARMLLOCAL"
CLEARMLUI="08.CLEARMLUI"
PIPINSTALL="09.PIPINSTALL"
PIPUPDATE="10.PIPUPDATE"
KUBENODE="11.KUBEGETNODES"
KUBEPOD="11.KUBEGETPODS"
KUBECREATE="12.KUBECREATE"
PINGTEST="PING"

FAILEDCOMPONENTS="${PINGTEST} ${GIT} ${APT16} ${APT18} ${DOCKERPUSH} ${DOCKERPULL} ${CLEARMLREMOTE}  ${CLEARMLUI} ${PIPINSTALL} ${KUBENODE} ${KUBEPOD} ${KUBECREATE} ${DOCKERBUILD}"

success () {
  FAILEDCOMPONENTS=${FAILEDCOMPONENTS//$1/}
  echo -e "${GREEN}\nSUCCESS!: $1 \n${NC}"
  echo -e "${RED}Components not tested or failed: ${FAILEDCOMPONENTS}${NC}\n"
}

pingtest () {
 echo -e "\n\nPerforming PING test for $1"
 for i in $1
 do 
   ping -c 2 $i
 done
 success ${PINGTEST}
}

gittest () {
  echo -e "\n\nPerforming ${GIT} test"
  docker run --rm myubuntu:18.04 /bin/bash -c "apt update && apt install -y git && git clone $1"
  success ${GIT}
}

dockertest () {
  if [ "$1" = "${DOCKERBUILD}" ]; then
     echo -e "\n\nPerforming $1 test"
     docker build -f Dockerfile.1804 -t myubuntu:18.04 .
     docker build -f Dockerfile.1604 -t myubuntu:16.04 .
     success $1
  elif [ "$1" = "${DOCKERPUSH}" ]; then
     echo -e "\n\nPerforming $1 test"
     docker build -f Dockerfile.1804 -t ${PUSHPULLIMAGE} .
     docker login ${DOCKERREPO}
     docker push ${PUSHPULLIMAGE}
     success $1
  elif [ "$1" = "${DOCKERPULL}" ]; then
     echo -e "\n\nPerforming $1 test"
     docker pull ${PUSHPULLIMAGE}
     success $1
  else
     echo -e "\n${RED}DOCKER TEST $1 DID NOT PROCEED AS EXPECTED!${NC}\n"
  fi
}

apttest () {
  if [ "$1" = "${APT18}" ]; then
    echo -e "\n\nPerforming $1 test"
    docker run --rm myubuntu:18.04 /bin/bash -c "apt update && apt install -y vim"
    success $1
  elif [ "$1" = "${APT16}" ]; then
    echo -e "\n\nPerforming $1 test"
    docker run --rm myubuntu:16.04 /bin/bash -c "apt update && apt install -y vim"
    success $1
  fi
}

piptest () {
  if [ -d ./venv ]; then
    sudo rm -r venv
  fi
  python3 -m venv venv
  source venv/bin/activate
  pip install --upgrade pip
  success ${PIPINSTALL}
}

kubetest () {
  if [ "$1" = "${KUBENODE}" ]; then
    kubectl get nodes
    success $1
  elif [ "$1" = "${KUBEPOD}" ]; then
    if [[ "$(kubectl get pods)" == *"pod-httpd"* ]]; then
      success $1
    fi
  elif [ "$1" = "${KUBECREATE}" ]; then
    if [[ "$(kubectl get pods)" == *"pod-httpd"* ]]; then
      kubectl delete -f simple.yaml
    fi
    kubectl create -f simple.yaml 
    success $1
  fi
}


clearmltest () {
  if [ "$1" = "${CLEARMLUI}" ]; then
    HTMLOUTPUT="$(curl ${CLEARMLSERVER} | grep ClearML)"
    if [ ${HTMLOUTPUT} = "<title>ClearML</title>" ]; then
       success $1
    fi
  elif [ "$1" = "${CLEARMLREMOTE}" ]; then
    docker run myubuntu:18.04 /bin/bash -c "apt update && apt install -y git python3-dev python3-venv && git clone ${GITLINK} && cd ${GITFOLDER}/detectron2/codes && python3 -m venv venv && source venv/bin/activate && pip install --upgrade pip && pip install setuptools wheel clearml && python runremotetrain.py"
    echo "CHECK ${CLEARMLSERVER} FOR RUNNING TASK FOR RUNNING TASK"
    success $1
  elif [ "$1" = "${CLEARMLLOCAL}" ]; then 
    echo "To implement" 
  fi
}


pingtest ${PINGLIST}
dockertest ${DOCKERBUILD}
dockertest ${DOCKERPUSH}
dockertest ${DOCKERPULL}
apttest ${APT16}
apttest ${APT18}
gittest ${GITLINK}
piptest 
clearmltest ${CLEARMLUI}
kubetest ${KUBENODE}
kubetest ${KUBECREATE}
kubetest ${KUBEPOD}
clearmltest ${CLEARMLREMOTE}
