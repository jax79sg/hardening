FROM ubuntu:18.04
RUN apt update && apt install -y git vim build-essential
RUN git clone https://github.com/Stifler6996/apt-mirror
COPY mirror.list.18.04 /apt-mirror/mirror.list 
